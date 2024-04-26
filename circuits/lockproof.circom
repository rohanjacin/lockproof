pragma circom 2.0.3;

include "../circom-ecdsa/circuits/secp256k1.circom";
include "../circom-ecdsa/circuits/secp256k1_func.circom";

template Shared (n, k) {
	signal input privkey[k];
    signal input lockpubkey[2][k];
	signal output out[2][k];

	component shared = Secp256k1ScalarMult(n, k);
	for (var idx = 0; idx < k; idx++) {
		shared.scalar[idx] <== privkey[idx];
		shared.point[0][idx] <== lockpubkey[0][idx];
		shared.point[1][idx] <== lockpubkey[1][idx];
	}

	for (var idx = 0; idx < k; idx++) {
		out[0][idx] <== shared.out[0][idx]; 
		out[1][idx] <== shared.out[1][idx]; 
	}	
}

template negShared (n, k) {
	signal input in[2][k];
	signal output out[2][k];

	component neg = InvPoint(n, k);
	for (var idx = 0; idx < k; idx++) {
		neg.point[0][idx] <== in[0][idx];
		neg.point[1][idx] <== in[1][idx];
	}

	for (var idx = 0; idx < k; idx++) {
		out[0][idx] <== neg.out[0][idx];
		out[1][idx] <== neg.out[0][idx];
	}
}

template LockAuth (n, k) {
	signal input cipherpoint1[2][k];
	signal input cipherpoint2[2][k];
	signal input privkey[2][k];
	signal input expectedPm[2][k];

	component sharedPoint = Shared(n, k);

	for (var idx = 0; idx < k ; idx++) {
		sharedPoint.privkey[idx] <== privkey[0][idx]; 
	}

	for (var idx = 0; idx < k ; idx++) {
		sharedPoint.lockpubkey[0][idx] <== cipherpoint1[0][idx]; 
		sharedPoint.lockpubkey[1][idx] <== cipherpoint1[1][idx]; 
	}

	signal temp[2][k];

	for (var idx = 0; idx < k ; idx++) {
		temp[0][idx] <== sharedPoint.out[0][idx];
		temp[1][idx] <== sharedPoint.out[1][idx];
	}

	component negshared = negShared(n, k);

	for (var idx = 0; idx < k ; idx++) {
		negshared.in[0][idx] <== temp[0][idx];
		negshared.in[1][idx] <== temp[1][idx];
	}

	component secret = Secp256k1AddUnequal(n, k);

	for (var idx = 0; idx < k ; idx++) {
		secret.a[0][idx] <== cipherpoint2[0][idx];
		secret.a[1][idx] <== cipherpoint2[1][idx];
		secret.b[0][idx] <== negshared.out[0][idx];
		secret.b[1][idx] <== negshared.out[1][idx];
	}

	signal Pm[2][k];

	for (var idx = 0; idx < k ; idx++) {
		Pm[0][idx] <== secret.out[0][idx];
		Pm[1][idx] <== secret.out[1][idx];
	}

	expectedPm <== Pm;
}

template InvPoint(n, k) {
    signal input point[2][k];
    var x[100];
    var y[100];

    for(var i = 0; i < k; i++){
        x[i] = point[0][i];
        y[i] = point[1][i];
    }

    var p[100] = get_secp256k1_prime(n, k);
    
    signal output out [2][k];

    var neg_y[100] = long_sub_mod_p(n, k, p, y, p);

    var temp[k];

    for (var idx = 0; idx < k; idx++) {
        out[0][idx] <== point[0][idx];
        out[1][idx] <-- neg_y[idx];
        out[1][idx] === neg_y[idx];
    }
}

component main { public [ cipherpoint1, cipherpoint2 ] } = LockAuth(64, 4);