(~pFMono.(data: ~data, index: 1, fdeg: 24) <> ~chordSeq.(~data)).play;

(
~chordSeq = {|dur = 2, leg =1|
	var chrds, pChords;


	pChords = {|degs|
		Psync(
			Pbind(
				\degree,		degs.postln,
				\legato, 		leg,
				\amp, 			0.6,
				\octave, 5,
				\dur, dur,
		),4,dur
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
	o;
};
)

~pFMono.(data: ~data, index: 0.5, fdeg: 0, env: [0.01,0,1,0.1]) <>
~chordSeq.().play;





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
		a: Psync(Ppar([ d[0].() 								])	<>~tn.(~data,0),4,8),
		b: Psync(Ppar([	d[0].() , d[2].() , d[8]				])	<>~tn.(~data,0),4,8),
		c: Psync(Ppar([ d[8].() , d[2].()						])	<>~tn.(~data,6),4,8 ),
		d: Psync(Ppar([ d[2].()	, d[7].()						])	<>~tn.(~data,0),4,8),
		e: Psync(Ppar([ d[3].() , d[4].() , d[5].() , d[6].()	])	<>~tn.(~data,5),4,8),
		f: Psync(Ppar([ d[2].()	, d[7].() 						])	<>~tn.(~data,5),4,8),
	);
};

)

Psym(Pseq([\c]), ~parts.()).play;

d=Array.fill(10);
(
d[0] = { ~pDcm.(~data, 2, 64, ix: 10, mp:1, cp: 1, st: 3) };
d[1] = { ~pDcm.(~data, 3.5, 64, ix: 10, mp:1, cp: 1, st: 3) };
d[2] = { ~pFMo.(~data, ieamm: 2, fdeg: 0) <> ~arpFM.(~data,4) <> Pstutter(2,~chord3.([1],7,8,arp:1))};
d[3] = { ~pingM.(5,1) <> ~arpFM.(~data,2) <> Pstutter(1,~chord3.([1],7,arp:1)) };
d[4] = { ~pingM.(6,1) <> ~arpFM.(~data,3) <> Pstutter(1,~chord3.([1],7,arp:1)) };
d[5] = { ~pingM.(4,1) <> ~arpFM.(~data,1) <> Pstutter(1,~chord3.([1],7,arp:1)) };
d[6] = { ~pingM.(7,1) <> ~arpFM.(~data,4) <> Pstutter(1,~chord3.([1],7,arp:1)) };
d[7] = { ~pingM.(5,1) <> ~melodi.(~data,[0],8) 	} ;
d[8] = { ~pingM.(6,1,mel:1) <> ~melodi.(~data,[0],8,1) };
)

d = d.scramble
d[8].().play

~data = 7.collect( { 1-0.2.rand } );
Psym( Pseq([\d,\f,\c]), ~parts.() ).play;

Pdelay

d[2].play

(~pFMo.(~data, ieamm: 2, fdeg: 0)<> ~arpFM.(~data,2)<> Pstutter(2,~chord3.([1],7,arp:1)) ).play



Pseq([d[0],d[1]]).play



(~pFMo.(~data, ieamm: 2)<>Pstutter(2,~melodi.(~data,[0],8,1))).play
s.plotTree




(~pingM.(5,1)<>~chord3.([5],arp:1)).play




~chord3.([1],arp:0).play








// STRUKTURTEST

~data = 7.collect( { 1-0.2.rand } );

(
~parts = {
	(
		a: Psync(Ppar( 1.collect(	{|i,n| 	d[i].()}	) 		)	<>~tn.(~data,0),4,4),
		b: Psync(Ppar( 2.collect(	{|i,n| 	d[i].()}	) 		)	<>~tn.(~data,0),4,4),
		c: Psync(Ppar( 3.collect(	{|i,n| 	d[i].()}	) 		)	<>~tn.(~data,0),4,4),
		d: Psync(Ppar( 4.collect(	{|i,n| 	d[i].()}	) 		)	<>~tn.(~data,0),4,4),
		e: Psync(Ppar( 5.collect(	{|i,n| 	d[i].()}	) 		)	<>~tn.(~data,0),4,4),
		f: Psync(Ppar( 6.collect(	{|i,n| 	d[i].()}	) 		)	<>~tn.(~data,0),4,16),
		g: Psync(Ppar([d[5].()	] 		)	<>~tn.(~data,0),4,16),
	);
};

)

x = Psym(Pseq([\a,\e,]), ~parts.()).play;
x.stop


(
d=Array.fill(7);
d[0] = { ~pDcm.(~data, 2, 60, ix: 10, mp:1, cp: 1, st: 3, amp: 1) };
d[1] = { ~pDcm.(~data, 3.5, 64, ix: 10, mp:1, cp: 1, st: 3, amp: 0.5) };
d[2] = { ~pFMo.(~data, ieamm: 2, fdeg: 0) <> ~arpFM.(~data,4) <> Pstutter(2,~chord3.([1],7,8,arp:1))};
d[3] = { ~pingM.(5,1) <> ~arpFM.(~data,2) <> Pstutter(1,~chord3.([1],7,arp:1)) };
d[4] = { ~pingM.(7,1) <> ~arpFM.(~data,4) <> Pstutter(1,~chord3.([1],7,arp:1)) };
d[5] = { ~pingM.(6,1,1) <> ~melodi.(~data,[0]) 	} ;
d[6] = { ~pingM.(6,1,mel:1) <> ~melodi.(~data,[0]) };
)

d
d = d.scramble;

d[1].().play

s.plotTree


d[5].().play



5.collect(	{|i,n| i.postln;	d[i].(); }	)

{ ~pingM.(6,1) <> ~melodi.(~data,[0],8)<>~tn.(~data,0) }.().play;
{ ~pFMo.(~data, ieamm: 2, fdeg: 0) <> Pstutter(2,~melodi.(~data,[0],8)) }.().play;









// DRONEPUSSEL
/*
(
~parts = {
| len = 16, d |
//d = d.scramble;
(
a: Psync(Ppar( 1.collect(	{|i| 	d[i].()}	) 		)	<>~tn.(~data,0),4,len),
b: Psync(Ppar( 2.collect(	{|i| 	d[i].()}	) 		)	<>~tn.(~data,0),4,len),
c: Psync(Ppar( 3.collect(	{|i| 	d[i].()}	) 		)	<>~tn.(~data,0),4,len),
d: Psync(Ppar( 4.collect(	{|i| 	d[i].()}	) 		)	<>~tn.(~data,0),4,len),
e: Psync(Ppar( 5.collect(	{|i| 	d[i].()}	) 		)	<>~tn.(~data,0),4,len),
f: Psync(Ppar( 6.collect(	{|i| 	d[i].()}	) 		)	<>~tn.(~data,0),4,len),
);
};

)



x = (Psym(Pseq(~parts.(d:d).keys), ~parts.(4,d))).play; //<> Pn(Pstutter(8,~melodi.(~data,[0],32,tmp:10),20))
x.stop
*/


(
~parts = {
	|d,le=16,t=0|
	//d = d.scramble;
	d.collect {|i,n|
		Psync(Ppar( (n+1).collect(	{|i| 	d[i].()}	) )	<>~tn.(~data,t),4,le)
	};
};

~parts2 = {
	|d,le=16,dec=1|

	d = d.rotate(~root.(~data));

	Ptpar(
		d.collect {|i,n| 	[le*n, Psync(d[n].(),4,le*dec)] }.flatten ++
		d.collect {|i,n|    [(le*n)+(le*d.size), Psync(d[n].()<>~tn.(~data,5),4,le*dec)]}.flatten ++
		[le*2.5, Psync(~ping.(5,7,a: 0.2,flt:400)<>~chordSeq.(le*2,0.75)<>~tn.(~data,0),4,d.size*2*le)]
	,inf);

};

)

~data = 7.collect( { 1-0.2.rand } );
	~decoder = FoaDecoderKernel.newSpherical;

~parts2.(d,4,3).play;

d.rotate(~root.())
~root.()

(
d = Array.fill(6);
d[0] = { ~pDcm.(~data, 2,	60, ix: 5,  mp:1, cp: 1, st: 2, amp: 1.5, env: [30,0,1,30]) };
d[1] = { ~pDcm.(~data, 3.5, 64, ix: 1,	mp:2, cp: 2, st: 2, amp: 0.5, env: [30,0,1,30]) };
d[2] = { ~pDcm.(~data, 5,	61, ix: 1,	mp:5, cp: 1, st: 1, amp: 0.5, env: [30,0,1,30]) };
d[3] = { ~pDcm.(~data, 1,	61, ix: 5,	mp:1, cp: 1, st: 1, amp: 1, env: [30,0,1,30]) };
d[4] = { ~pDcm.(~data, 5,	64, ix: 10, mp:~root.(~data), cp: 1, st: 2, amp: 0.1, env: [30,0,1,30]) };
d[5] = { ~pDcm.(~data, 6,	64, ix: 5,	mp:~root.(~data), cp: 1, st: 2, amp: 0.1, env: [30,0,1,30])  };
)
















Psync(~ping.(5,7,a: 0.2,flt:200)<>~chordSeq.(30,0.75)<>~tn.(~data,0),4,4).play

(~ping.(5,7,a: 0.2,flt:200)<>~chordSeq.(30,0.75)<>~tn.(~data,0)).play

x = PmonoArtic(
	\reson2,
	\in, 100,
	\legato, 0.2,
	\dur, Pseq([1,4,2,3],inf),
	\addAction, 1,
	\degree, [2,4,7],
	\fb, 0.9,
	\octave, 3,
	\scale, ~scaleBuilder.(~data),
	\root, ~root.(~data),
);

x.play
x.stop
~pDcm.(~data, 2, 60, ix: 2, mp:1, cp: 1, st: 3, amp:0.1, env: [0,0,1,30]).play;




(
Pseq(~parts2.(d,16)).play;

)




(Ptpar( d.collect {|i,n| 	[16*n, d[n].()] }.flatten )<>~tn.(~data)).play


scramble
d[5].().play







// DRONE 2 PUSSEL


(
//~data = 7.collect( { 1-0.2.rand } );

~pDrone = { | data, octave, dev = 2,amp=0.5 |
	Pmono(*[
		\droneWrench,
		amp: amp,
		octave: octave,
		data: [data],
		mod: 2,
		env: [[30,0,1,20]],
		summa: abs(LinLin.kr(data.sum/7, 0.7, 1.0, dev, 0)),
		phase: LinLin.kr(data.sum/7,data.minItem, data.maxItem,pi/2,-pi/2)
/*		group: ~sG*/
	])
};
~pDrone.(data: ~data, octave: 1).play;
)

~parts2 = {
	|d,le=16,dec=1|

	//d = d.rotate(~root.(~data));

	Ptpar(
		d.collect {|i,n| 	[le*n, Psync(d[n].(),4,le*dec)] }.flatten //++
		//d.collect {|i,n|    [(le*n)+(le*d.size), Psync(d[n].()<>~tn.(~data,5),4,le*dec)]}.flatten ++
		//[le*2.5, Psync(~ping.(5,7,a: 0.2,flt:400)<>~chordSeq.(le*2,0.75)<>~tn.(~data,0),4,d.size*2*le)]
	,inf);

};

~data = 7.collect( { 1-0.2.rand } );
~parts2.(d,4,4).play


(
d = Array.fill(9);
d[0] = { ~pDrone.(~data, 1,5,amp:1)<>(degree: 0) };
d[1] = { ~pDrone.(~data, 2)<>(degree: 2) };
d[2] = { ~pDrone.(~data, 3)<>(degree: 4) };
d[3] = { ~pDrone.(~data, 3)<>(degree: 0) };
d[4] = { ~pDrone.(~data, 3)<>(degree: 2) };
d[5] = { ~pDrone.(~data, 2)<>(degree: 7) };
d[6] = { ~pDrone.(~data, 1)<>(degree: 6) };
d[7] = { ~pDrone.(~data, 4)<>(degree: 3) };
d[8] = { ~pDrone.(~data, 5,amp:0.2)<>(degree: 3) };
)

s.plotTree


(
~drone2 = {|le=16,dec=4|

	~pDrone = { | data, octave, dev = 2,amp=0.5 |
		Pmono(*[
			\droneWrench,
			amp: amp,
			octave: octave,
			data: [data],
			mod: 2,
			env: [[30,0,1,20]],
			summa: abs(LinLin.kr(data.sum/7, 0.7, 1.0, dev, 0)),
			phase: LinLin.kr(data.sum/7,data.minItem, data.maxItem,pi/2,-pi/2)
		])
	};

	d = Array.fill(9);
	d[0] = { ~pDrone.(~data, 1,5,amp:1	)<>(degree: 0) };
	d[1] = { ~pDrone.(~data, 2			)<>(degree: 2) };
	d[2] = { ~pDrone.(~data, 3			)<>(degree: 4) };
	d[3] = { ~pDrone.(~data, 3			)<>(degree: 0) };
	d[4] = { ~pDrone.(~data, 3			)<>(degree: 2) };
	d[5] = { ~pDrone.(~data, 2			)<>(degree: 7) };
	d[6] = { ~pDrone.(~data, 1			)<>(degree: 6) };
	d[7] = { ~pDrone.(~data, 4			)<>(degree: 3) };
	d[8] = { ~pDrone.(~data, 5,amp:0.2	)<>(degree: 3) };


	Pspawn(
		Pbind(
			\pattern, {Pxrand(d.collect{|i,n| Psync(d[n].(),4,le*dec)})},
			    \delta, le,
			    \method, Pseq([\par,Prand([\par,\wait],inf)]),
		)
	)
};
)

(~drone2.()<>~tn.()).play;













(Pn(~chord3.(8,7))<>~arpFM.(2,4)<>~tn.(~data)).play







~metaPlayer = {
	var picker, out=0;
	picker = ~root.()%4;


	[
		~playMETAFYX.(out),
		~playDRONEFM.(out),
		~playSAMPLER.(out),
		~playDRONE2.(out)
	].at(picker);
};




~data = 7.collect( { 1-0.2.rand } );
//~root.(~data)
~playIt = ~metaPlayer.().play
)
~playIt.stop


~playDRONEFM.(~ambiBus).play
~playDRONEFM.(0).play

Synth(\wrenchVerb,[\out,~ambiBus], target: ~groups[7],addAction:0);
Synth(\ambiOut, target: ~groups[7],addAction:1);


~reverbSend


(~sendOSC<>~tn.()<>~playMETAFYX.(0)).play
(~sendOSC<>~tn.()<>~playDRONEFM.(0)).play
(~tn.()<>~playSAMPLER.(0)).play
(~sendOSCA<>~tn.()<>~playDRONE2.(0)).play


~sendOSC = Pbind(
	\sendings, Pfunc({|ev| ~snd.sendMsg("/fx", ev.degree, ~sndThings[ev.degree].next ) }),
);

~sendOSCA = Pbind(
	\sendings, Pfunc({|ev| ~snd.sendMsg("/fx", ev.octave, ~sndThings[ev.octave].next ) }),
);



~metaPlayer.().play


x = OSCFunc.newMatching({|msg, time, addr, recvPort| msg.postln}, '/fx', n); // path matching


~sndOSC

s.plotTree



