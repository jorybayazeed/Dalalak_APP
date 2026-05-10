#!/usr/bin/env node
/**
 * cleanup-tours.js
 *
 * يحذف بيانات التور غير المكتملة والتجريبية من Firestore (collection: tourPackages).
 *
 * الاستخدام:
 *   1) ضع ملف service-account key في: scripts/serviceAccount.json
 *      (تنزله من: Firebase Console → Project settings → Service accounts → Generate new private key)
 *   2) من الترمنال:
 *        cd scripts
 *        npm install firebase-admin
 *
 *   3) معاينة فقط (ما يحذف):
 *        node cleanup-tours.js
 *
 *   4) وضع تأكيد فردي (يسأل قبل كل حذف):
 *        node cleanup-tours.js --interactive
 *
 *   5) حذف جماعي بدون أسئلة (بعد ما تتأكدين من المعاينة):
 *        node cleanup-tours.js --delete
 *
 * ملاحظة: السكربت لا يلمس أي collection ثاني — فقط tourPackages.
 */

const path = require('path');
const readline = require('readline');
const admin = require('firebase-admin');

const SERVICE_ACCOUNT_PATH = path.resolve(__dirname, 'serviceAccount.json');
const DELETE_MODE = process.argv.includes('--delete');
const INTERACTIVE_MODE = process.argv.includes('--interactive');

// قائمة IDs لاستثنائها من الحذف حتى لو طابقت المعايير (Allow-list)
// إذا شفتي تور حقيقي طلع في المعاينة، انسخي ID وحطيه هنا.
const KEEP_THESE_IDS = [
  // 'abc123XYZ',
  // 'def456...',
];

// ===================== المعايير =====================
// كلمات تدل إن التور تجريبي (تطابق بدون حساسية لحالة الأحرف)
const TEST_KEYWORDS = [
  'test', 'testing', 'tst', 'demo', 'sample', 'example',
  'asdf', 'qwer', 'xxx', 'abc', '123',
  'تجربة', 'تجريبي', 'تجريبية', 'اختبار', 'تست',
];

// شروط "غير مكتمل" — لو واحد منها صح، التور يعتبر ناقص
function isIncomplete(data) {
  const reasons = [];
  if (!data.tourTitle || String(data.tourTitle).trim() === '') reasons.push('بدون عنوان');
  if (!data.destination || String(data.destination).trim() === '') reasons.push('بدون وجهة');
  if (!data.tourDescription || String(data.tourDescription).trim() === '') reasons.push('بدون وصف');
  if (!Array.isArray(data.activities) || data.activities.length === 0) reasons.push('بدون أنشطة');
  return reasons;
}

function isTestTour(data) {
  const title = String(data.tourTitle || '').toLowerCase().trim();
  const desc = String(data.tourDescription || '').toLowerCase().trim();
  for (const kw of TEST_KEYWORDS) {
    if (title.includes(kw.toLowerCase()) || desc.includes(kw.toLowerCase())) {
      return `يحتوي كلمة "${kw}"`;
    }
  }
  return null;
}

// =====================================================

(async () => {
  try {
    const serviceAccount = require(SERVICE_ACCOUNT_PATH);
    admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
  } catch (e) {
    console.error('❌ ما لقيت ملف serviceAccount.json في مجلد scripts/');
    console.error('   نزله من Firebase Console → Project settings → Service accounts');
    process.exit(1);
  }

  const db = admin.firestore();
  console.log(DELETE_MODE
    ? '⚠️  وضع الحذف الفعلي — راح يتم حذف المستندات!'
    : '🔍 وضع المعاينة فقط (ما يحذف). أضف --delete للحذف الفعلي.\n');

  const snap = await db.collection('tourPackages').get();
  console.log(`📦 إجمالي التورات: ${snap.size}\n`);

  const toDelete = [];
  let kept = 0;

  let skippedByAllowList = 0;
  for (const doc of snap.docs) {
    const data = doc.data();

    // حماية: استثناء الـIDs اللي حطّيتيها يدوياً
    if (KEEP_THESE_IDS.includes(doc.id)) {
      skippedByAllowList++;
      kept++;
      continue;
    }

    const incompleteReasons = isIncomplete(data);
    const testReason = isTestTour(data);

    if (incompleteReasons.length > 0 || testReason) {
      toDelete.push({
        id: doc.id,
        title: data.tourTitle || '(بدون عنوان)',
        guideId: data.guideId || '?',
        reasons: [
          ...(testReason ? [`تجريبي: ${testReason}`] : []),
          ...incompleteReasons.map(r => `ناقص: ${r}`),
        ],
      });
    } else {
      kept++;
    }
  }

  if (skippedByAllowList > 0) {
    console.log(`🛡️  تورات محمية بواسطة KEEP_THESE_IDS: ${skippedByAllowList}`);
  }

  if (toDelete.length === 0) {
    console.log('✅ ما فيه تورات تستحق الحذف بناءً على المعايير.');
    process.exit(0);
  }

  console.log(`🗑️  مرشّحون للحذف: ${toDelete.length}`);
  console.log(`✅ يبقى:           ${kept}\n`);

  toDelete.forEach((t, i) => {
    console.log(`${i + 1}. [${t.id}] "${t.title}" (guide: ${t.guideId})`);
    t.reasons.forEach(r => console.log(`     - ${r}`));
  });

  if (!DELETE_MODE && !INTERACTIVE_MODE) {
    console.log('\n💡 هذي معاينة فقط. خياراتك:');
    console.log('   node cleanup-tours.js --interactive   ← يسأل قبل كل حذف');
    console.log('   node cleanup-tours.js --delete        ← حذف جماعي');
    process.exit(0);
  }

  // وضع التأكيد الفردي
  if (INTERACTIVE_MODE) {
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
    const ask = (q) => new Promise((res) => rl.question(q, res));

    let deleted = 0, skipped = 0;
    console.log('\n📋 وضع التأكيد الفردي — اضغطي y للحذف، n للتخطّي، q للخروج.\n');
    for (let i = 0; i < toDelete.length; i++) {
      const t = toDelete[i];
      console.log(`\n[${i + 1}/${toDelete.length}] ${t.title}`);
      console.log(`   ID: ${t.id} | guide: ${t.guideId}`);
      t.reasons.forEach(r => console.log(`   - ${r}`));
      const ans = (await ask('   احذف؟ (y/n/q): ')).trim().toLowerCase();
      if (ans === 'q') break;
      if (ans === 'y') {
        await db.collection('tourPackages').doc(t.id).delete();
        console.log('   ✅ حُذف');
        deleted++;
      } else {
        console.log('   ⏭️  تم التخطّي');
        skipped++;
      }
    }
    rl.close();
    console.log(`\n✅ خلصنا. حُذف ${deleted}، تم تخطّي ${skipped}.`);
    process.exit(0);
  }

  // الحذف الجماعي
  console.log('\n⏳ جاري الحذف...');
  let deleted = 0;
  for (const t of toDelete) {
    await db.collection('tourPackages').doc(t.id).delete();
    deleted++;
    process.stdout.write(`\r   تم حذف ${deleted}/${toDelete.length}`);
  }
  console.log(`\n✅ خلصنا. حُذف ${deleted} تور.`);
  process.exit(0);
})().catch(err => {
  console.error('❌ فشل:', err.message);
  process.exit(1);
});
