/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
//const functions = require('firebase-functions');
//const admin = require('firebase-admin');
//admin.initializeApp();
//
//exports.calculateBalance = functions.firestore
//    .document('transactions/{transactionId}')
//    .onWrite(async (change, context) => {
//        // Tranzaksiya ma'lumotlarini olish
//        const transaction = change.after.data();
//        const oldTransaction = change.before.data();  //oldingi qiymat
//        const debtorId = transaction.debtorId;
//        const amount = transaction.amount;
//        const isDebt = transaction.isDebt;
//      console.log("TRansactionid" +transaction.id);
//        // O'zgarish turini aniqlash (yaratish, yangilash, o'chirish)
//        let changeType = 'created';
//        if (change.before.exists && change.after.exists) {
//            changeType = 'updated';
//        } else if (!change.after.exists) {
//            changeType = 'deleted';
//        }
//        console.log("usertype" +changeType);
//        // 1. Debtorni olish
//        const debtorRef = admin.firestore().collection('debtors').doc(debtorId);
//        const debtorDoc = await debtorRef.get();
//
//        if (!debtorDoc.exists) {
//            console.log('Debtor topilmadi!');
//            return null;
//        }
//
//        let debtor = debtorDoc.data();
//        let currentBalance = debtor.balance || 0;
//
//        // 2. Balansni yangilash (tranzaksiya turiga qarab)
//        let newBalance = currentBalance;
//        switch (changeType) {
//            case 'created':
//                if (isDebt) {
//                    newBalance -= amount;  // true -> men qarzdorman, minus (-)
//                } else {
//                    newBalance += amount;  // false -> menga qarzdor, plus (+)
//                }
//                break;
//            case 'updated':
//                const oldAmount = oldTransaction.amount;
//                const oldIsDebt = oldTransaction.isDebt;
//
//                if (isDebt != oldIsDebt) {
//                    // Tip o'zgargan (isDebt)
//                    if (oldIsDebt) {
//                        newBalance += oldAmount;
//                        newBalance -= amount;
//                    } else {
//                        newBalance -= oldAmount;
//                        newBalance += amount;
//                    }
//                } else {
//                    // Miqdor o'zgargan
//                    newBalance += (amount - oldAmount);
//                }
//                break;
//            case 'deleted':
//                if (isDebt) {
//                    newBalance += amount;  // true -> men qarzdorman, plus (+)
//                } else {
//                    newBalance -= amount;  // false -> menga qarzdor, minus (-)
//                }
//                break;
//        }
//      console.log( "Balans:" +newBalance);
//        // 3. Debtorni yangilash
//        await debtorRef.update({
//            balance: newBalance,
//            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
//        });
//
//        console.log(`Debtor ${debtorId} uchun balans yangilandi: ${newBalance}`);
//        return null;
    });

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
