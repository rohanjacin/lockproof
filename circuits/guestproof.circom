pragma circom 2.1.5;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/babyjub.circom";
include "../node_modules/circomlib/circuits/binsum.circom";
include "../node_modules/circomlib/circuits/bitify.circom";

template CompareSign () {
	signal input message;
	signal input secret;
	//signal input s;
	signal input r;
	signal input ExpS;
	signal input ExpR[2];

	signal output S;
    signal s, hm;
	signal Rx, Ry;
	signal Ax, Ay;

    var l = 2736030358979909402780800718157159386076813972158567259200215660948447373041;
    var e = 21888242871839275222246405745257275088614511777268538073601725287587578984328;

	log("r:", r);
	log("secret:", secret);
	log("message:", message);

    //s <-- secret >> 3;
	
	// Check if s is in the prime subgroup order 'l'
	component scheck = LessThan(251);
	scheck.in[0] <== secret;
	scheck.in[1] <== l;
	scheck.out === 1;

	// A
    component key = BabyPbk();
    key.in <== secret;
    Ax <== key.Ax;
    Ay <== key.Ay;

	// Check if r is in the prime subgroup order 'l'
	component rcheck = LessThan(251);
	rcheck.in[0] <== r;
	rcheck.in[1] <== l;
	rcheck.out === 1;
   	
	// R
	component pointR = BabyPbk();
	pointR.in <== r;
	Rx <== pointR.Ax;  
	Ry <== pointR.Ay;
	log("Rx:", Rx);
	log("Ry:", Ry);
	log("ExpR[0]:", ExpR[0]);
	log("ExpR[1]:", ExpR[1]);

    // s
    component shash = Poseidon(5);
    shash.inputs[0] <== Rx;
    shash.inputs[1] <== Ry;
    shash.inputs[2] <== Ax;
    shash.inputs[3] <== Ay;
    shash.inputs[4] <== message;
	hm <== shash.out;
	log("hm:", hm);

	// S
	//signal m;
	//m <== secret*8;
	//log("m:", m);
	
	signal t;
	t <-- secret >> 3;
	signal _T;
	_T <== t;
	log("t:", t);
	log("_T:", _T);

	signal _S;
	_S <-- r + hm*_T;
	S <== _S;

	log("S:", S);
	log("ExpS:", ExpS);

	//ExpS === S;
	ExpR[0] === Rx;
	ExpR[1] === Ry;
}

component main { public [ message, ExpR, ExpS ] } = CompareSign();