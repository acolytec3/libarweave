import 'package:libarweave/libarweave.dart';

void main() async {
  var walletString = '''{
    "kty": "RSA",
    "e": "AQAB",
    "n": "ovFF6EbOtXeg7VnojIgtChgxfU6GZ16JjVj5JFHh6NGHJnq4p059BnMphcDx1mqb3yxM73FxhEszSFLcJiPzway6eIDiXuYiT-Sf_0Wl6_wDLvEmlz43psp7WYJumwpaSyiI_1FWmOVQnTnoAIKaOYKVqzUlteiECQj7XjJl0MZH16RlEfVqVpJ_8Ier4_QXIJ8Y3pe2KF3Lg9UANFU97nuvEM94CSzX-0WIju6Lykt3DBb2YtFFg4bJjOFv3T38nCZmDh8lYjm25_1qILalsB0XRoDxQy9FLxWb4zd09JsDhL0EYAQ_hNfOnQFVOBtYEHVYMCHYH6GoTcNgxmUkZPk4AfpAqZmjDzKfVJrw4Fr68pPTEQOQEzBcIWp61P21BSkhqO4QuFinkQsSH6NdTB_3FpbhYf34Hjf-iH7hdpdWo4aoRLb8eZeZcqBRZoRmlhQnOD-PVxQR_vb9rjXSjGkCWwRbsurVLWdBh_FQn0S9Q6EHqiV8nbW-R0Rk2E76JwgMFkqGUtZj8DeEqXJ2jlAvuzp56fXeAViPEtvUj1HheO8O3LxdVYCiapWWKq4qQVoRzdiyvydYSmbztgFUhekvmjNkxLNKOh71i3hFtoXycegqZ6izrUGoF2oD24lsTKsV5lV5pwfmUjVvxtHZm54bJIMfUDYbOV6yeDjYBb8",
    "d": "EePSrJeFn4f0a8rozPEwnMCeQmdKO3Q2PwYrSJES8Ch9IbzspDXqZThksTJHeya2WXD4O3vlnkRRa5npYOimnTeVO6DO-eNjlgkAhhsEBh5jzRYeChIDMzVdCK1Y7n3a_xCCxiGMk_nteW2_qrqsKy9KtoL90nSmdoV9b9CxvBPhFGyQykF7POkV0fdbaIpGtcayCNJ4ZgMyUpWi0ZwgUhxTUtGsmLlLN2Phg-vt_jZ96h5lS-E1NCUq4ORpj018fDp9DwTdamTyz5LTwaa8F1OCWDPVCW7Ztjs1o-NVXHvejYbhQZeFz9SP804PqLrb1ubDWXmFzKdHns4aRH4bWivh9L8HwSJUl5UEXprJUpYilT0tb3VauI7Cih2LBfhU3fUIDJFYm_j9etgNcPlqt64T7_TI8elgj7-sciXa1XEqIje9Mn8spxT6lpn4nhxJ9qelERCJwiWbuPnW2VsJHeqXZTly52KQEP_UBC4z8a0tDm7HIQw7WQ-OAuNUOu8ongOHaOexkqKYIcF3f812sOIVEJufoBXUUTIvJk-buH0ytgtTjkrO64zZeIvFHa1MFU-6UXh8jipSZ617znNR2Pc1-l3s7pACdbXvy2-5VWE3psRr1L5HM4KNwm6Rs5BXXqBSifzfiJ5qNGqKabfXvPXI8wYyl3mhUQtHW6sUUl0",
    "p": "0q_DP_FzSi8JEd-NNXoIaeL5MOxmNiXmDHGNxP3noKPyr-N6h3CrK5G59Rj2vWAJMhKToz1eSQ1p0-X0Ku2DvdT5LQOGIXVPtojw0OcOI8G8SoqMGAGehaLsnV3vexwtwjLfIM99XccKAxWMA1SMuL48nuBpMUhO0MlagbrL5vfpKB9kL7XCQqspAnN_vBmQZGWYczQmBgfC6v6xGQV3xHJmL--dn-qF2XU9pKuqd0J-cKYcdLPrccdJtGLid4nrSOTDfEbr77IUI5VGWV8CFJ-n8Vki-GwUxUkJpIoRyp5DxnYtSJb7cV-xOf7kBTCEUFn5B8fb2q-d8011cgnp5Q",
    "q": "xfzB-Yf4fa2y2q4ubJCJA5H-IG9-mr7fVRTUbj-gTqVL-I7MCDIImdAPbA-3EoIR5H70GVbAFGQJyYDq6eDeTbNs1zfnU0JPurASE3fKbOpoRdLwXwaSdRJRP9qnqUe-BzuloIzWc-dI-6TJxmHUSA1X9CtHvIdfNdKPCVFKUMrb1bv5arAI8tRbNRfy3tnbiw4wfKhYEQ1e6RPpxAR5F4We9RJ81-sIlfAy7WfliwmcGmgcPNdUinGR299CiVYKf5ktoqGFQ9n6K-v4gNZV23f33-tuD8pMVxyc3xG34j4frH57bsbm7v8Qz-92ZxHWzOUgxIVhGgSaa4E51d9m0w",
    "dp": "yArepo4I230BbZkHKKlv56n81PkAq5UccuA2rb4u-ZXxThP9OTA_NiUtnYxQassOsB53U91m8pHr06hZR5ExL0NSO-1Go-oQ_83SaWeZQ1YmA9i83-ZZr6VcaKbSReAhimxm825PKIVd-kOxJ1BWNOtb_7Yv6v0u6IrmhproE6t8E_6KT8qSYl7Fl3A27lCPiuPz9h6jo8Imzp15ZbqNV1cPs6Ad18MDx8_L8diVCJt4FlmCV0Sl3uhMERx6zumDHzkma4-jYXmCKa8Ilr7g6NgWy8_Ipnto1VFd-H6oGexficaXhH7my2UCj4B23H6OgwSKsVqQY3mvzV3Uj6zeCQ",
    "dq": "a0_ey6OZWnWFleYHH60PtrGw7l_AXZvLbVBG_CLcfwQ1M1oi2OZVpxkQ4t95uTxq-lCdegZ9QhAfBessaOwLUk5IVjbk2Un98RByG784JuS-8-mrg7YKOA5fn56idax_IWiBE46Cxnu8ITlmbHKmHw-sdpnm3hb50jB4evJmt3fcw_KI8_zKPORBM3vxljy7NJnSSh7s7QE0Sl0Svb427Drut6L3rAimtK5mzCseTcg9pkp707ZbClcYWfafF9VdB2A9TgMCOo6xfJEANsT18GkMH4B6PXDHBAhsNrRh2O0XOeWsfZStoyj5Mdt3b9JJfPFMW3h38yQ_lrmKYZQfJQ",
    "qi": "aDsPYxE-JBYsYhCYXSU7WsCrnFxNsRpFMcYXdmdryYIdQUpeemChDGzVJXLnJhE4cAS9TtLcNg82xZSKZvHrnkbFpRfSJxzEnvIXW4V0LHkxkxbmM0e9B7UrpYm6LKtvEY6I7L8wHFpHdOwV6NjY925oULEV156X0r55V7N0XF-jy3rbm71DCWRh6IDRghhCZQ3aNgJxE-OtnABqasaY6CQnTDRXLkGE0kq9GCx85-92fQLHMzvrMhr9m_2MHYJ_gZehL4j95CQzhD3Zh602D0YYYwRSsU4h5HGjlmN52pe-rfTLgwCJq5295s7qUP8TTMzbZAOM_hehksHpAaFghA"
}''';

  var myWallet = Wallet(walletString);
  myWallet.loadWallet(walletString);
  print('Wallet address: ${myWallet.address}');
  setPeer(peerAddress: 'http://arweave.net');
  var balance = await myWallet.balance();
  print('Wallet balance: ${balance}');
  var lastTxn = await myWallet.lastTransaction();
  print('Wallet\'s last transaction ID is: ${lastTxn}');
  var txnDetails = await Transaction.getTransaction(lastTxn);
  print('Last transaction reward :${txnDetails['reward']}');
  var txns = await myWallet.dataTransactionHistory();
  print('Last data transactions :${txns}');
  var txPrice = await Transaction.transactionPrice(100);
  print('Price for transaction of 100 bytes is: $txPrice Winston');
  var allTxns = await myWallet.allTransactionsFromAddress();
  print('Tx IDs for all transactions from ${myWallet.address}: $allTxns');
  allTxns = await myWallet.allTransactionsToAddress();
  print('Tx IDs for all deposits made to ${myWallet.address}: $allTxns');
  final txSignature = await myWallet.signTransaction(lastTxn, txPrice, targetAddress: 'bLkyTRJCYg8WxBKrjBwAaRe1H7HYDfXzl7YKCENvw-Q', quantity: '1');
  print('Raw transaction is: ${txSignature.toString()}');
  final response = await myWallet.postTransaction(txSignature, lastTxn, txPrice);
  print(response.statusCode);
}
