pragma circom 2.0.3;

include "../circom-ecdsa/circuits/ecdsa.circom";

template GuestAuth (n, k) {
	signal input pubkey[2][k];
	signal input msghash[k];
	signal input r[k];
	signal input s[k];

	component verify = ECDSAVerifyNoPubkeyCheck(n, k);

	for (var idx = 0; idx < k; idx++) {
		verify.r[idx] <== r[idx];
		verify.s[idx] <== s[idx];
		verify.msghash[idx] <== msghash[idx];
	}

	for (var idx = 0; idx < k; idx++) {
		verify.pubkey[0][idx] <== pubkey[0][idx];
		verify.pubkey[1][idx] <== pubkey[1][idx];
	}
	
	verify.result === 1; 
}

component main { public [r, s, msghash, pubkey] } = GuestAuth(64, 4);