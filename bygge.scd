(~pFMono.(data: ~data, index: 1, fdeg: 24) <> ~chordSeq.(~data)).play;

(
~chordSeq = {|i = 2|
	var chrds, pChords;


	pChords = {|degs|
		Pbind(
			\degree,		degs.postln,
			\legato, 		1,
			\amp, 			0.6,
			\dur, 			Pseq([1],1),
			\octave, 5
		)
	};


	o = Pfsm([
		#[1], // entry states

		pChords.([0,0,0]),
		#[1],

		// I
		pChords.([0,2,4]),
		#[1,2,2,4,9,9,9],

		// II
		pChords.([1,3,5]),
		#[3,5,1],

		// III
		pChords.([2,4,6]),
		#[4],

		// IV
		pChords.([3,5,7]),
		#[5,2],

		// V
		pChords.([4,6,8]),
		#[1,6,3],

		// VI
		pChords.([5,7,9]),
		#[2],

		// VII
		pChords.([6,8,10]),
		#[8],

		// VIII
		pChords.([7,9,11]),
		#[1],

		// Vm
		pChords.(#[0,2,-2]),
		#[2, 5],


		// terminal state
		nil, nil
	]);
	Pstutter(i,o);
};

(~pFMono.(data: ~data, index: 0.5, fdeg: 0, env: [0.01,0,1,0.1]) <> ~chordSeq.()).play;
)






Psym












(
~data = 7.collect( { 1-0.1.rand } );
~pDcm.(data: ~data, octave: 2, index: 2, amm: ~data, deg: 0, st: 3).play;

)
~pDcm.(data: ~data, octave: 3.5, index: 2,bus:64, amm: ~data, deg: 0, st: 3).play

~pDcm.(data: ~data, octave: 6, index: 2,bus:67, amm: ~data, deg: 0, st: 3).play



Pchain(~pDcm.(data: ~data, octave: 2, index: 2,bus:60, amm: ~data, st: 3),Pstutter(24,~pTrans)).play


~pTrans = Pbind(
	\ctranspose, Pseq([0,3,5],inf),
	\dur, 2,
);



~pTrans.play



s.plotTree
















(
SynthDef(\help_Pdfsm1,
    { arg out=0, freq=440, sustain=0.05;
        var env;
        env = EnvGen.kr(Env.perc(0.01, sustain, 0.2), doneAction:2);
        Out.ar(out, SinOsc.ar([freq, freq + 0.1.rand2], 0, env))
    }).add;
)






(
var p;
p = Pdfsm(
    [
        Pseq([1,1,0],inf),    // signalStream

        IdentityDictionary[    // state 0
            0 -> [ 1, ~chord3.(1) ],
            1 -> [ 1, ~chord3.(11) ],
            2 -> [ 1, 65 ]
        ],
        IdentityDictionary[    // state 1
            0 -> [ 0, ~chord3.(2)  ],
            1 -> [ 0, ~chord3.(7)  ]
        ],
        IdentityDictionary[
            0 -> [ 1, 71 ],
            1 -> [ 0, 72 ],
            2 -> [ nil ]    // signalStream is infinitely long,
                    // so the fsm only ends because of this nil
                    // 2 -> [nil, nil] is also fine
        ]
    ],
    0,                 // startState
    1                 // repeats
);
p.play
)
Routine({
    var freq;
    while({ (freq = p.next.postln).notNil },{
        Synth(\help_Pdfsm1, [ \freq, freq.midicps ]);
        0.1.wait;
    })
}).play;
)























TempoClock.default.tempo = 60/60;


(
~parts = (
	a: Ppar([~chord3.(1) ,~chord3.([1],arp:1)			]	),
	b: Ppar([~chord3.(2) ,~chord3.([2],arp:1)			]	),
	c: Ppar([~chord3.(3) ,~chord3.([3],arp:1)			]	),
	d: Ppar([~chord3.(4) ,~chord3.([4],arp:1)			]	),
	e: Ppar([~chord3.(5) ,~chord3.([5],arp:1)			]	),
);

Psym(Pseq([\a,\b,\c,\d,\e]), ~parts).play;
)





(
~parts = {
	(
		a: Pfindur(16, Ppar([ d[0]	]	)),
		b: Pfindur(8, Ppar([d[0],d[2],d[8]	]	)<>~tn.(~data,0) ),
		c: Pfindur(4, Ppar([~chord3.([1],8,arp:1),d[2]	]	)<>~tn.(~data,1) ),
		d: Psync(Ppar([ d[2].()	, d[7].()		]	)<>~tn.(~data,0),4,8),
		e: Psync(Ppar([ d[3].() , d[4].() , d[5].() , d[6].()		]	)<>~tn.(~data,5),4,8),
		f: Psync(Ppar([ d[2].()	, d[7].() 		]	)<>~tn.(~data,5),4,8),
	);
};

)

Psym(Pseq([\d,\f,\c]), ~parts.()).play;

d=Array.fill(10);
d[0] = { ~pDcm.(~data, 2, 64, ix: 10, mp:1, cp: 1, st: 3) };
d[1] = { ~pDcm.(~data, 3.5, 64, ix: 10, mp:1, cp: 1, st: 3) };
d[2] = { ~pFMo.(~data, ieamm: 2, fdeg: 0) <> ~arpFM.(~data,4) <> Pstutter(2,~chord3.([1],7,8,arp:1))};
d[3] = { ~pingM.(5,1) <> ~arpFM.(~data,2) <> Pstutter(1,~chord3.([1],7,arp:1)) };
d[4] = { ~pingM.(6,1) <> ~arpFM.(~data,3) <> Pstutter(1,~chord3.([1],7,arp:1)) };
d[5] = { ~pingM.(4,1) <> ~arpFM.(~data,1) <> Pstutter(1,~chord3.([1],7,arp:1)) };
d[6] = { ~pingM.(7,1) <> ~arpFM.(~data,4) <> Pstutter(1,~chord3.([1],7,arp:1)) };
d[7] = { ~pingM.(5,1) <> ~melodi.(~data,[0],5) 	} ;
d[8] = { ~pingM.(6,1) <> Ptpar([4,~melodi.(~data,[16],8)]) };

d = d.scramble


~data = 7.collect( { 1-0.2.rand } );
Psym( Pseq([\d,\f,\c]), ~parts.() ).play;

Pdelay

d[2].play

(~pFMo.(~data, ieamm: 2, fdeg: 0)<> ~arpFM.(~data,2)<> Pstutter(2,~chord3.([1],7,arp:1)) ).play



Pseq([d[0],d[1]]).play



(~pFMo.(~data, ieamm: 5)<>Pstutter(2,~melodi.(~data,[0,16],8))).play
s.plotTree



Pflatten

~chord3.(5).play


~pingM = {|oct = 5, p = 2, lg= 1, a =0.5, flt= 500|
	PmonoArtic(
		\pinguPingu,
		\legato, 		1/lg,
		\amp, 			a,
		\filtr,			flt,
		\octave,		oct,
		\pan, 			Pwhite(-1,1,inf),
		*~pinguPresets.at(p),
	)
};


(~pingM.(5,1)<>~chord3.([5],arp:1)).play















~chord3.([1],arp:0).play
















