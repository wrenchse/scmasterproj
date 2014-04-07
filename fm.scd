// FM FM FM FM FM FM FM FM FM FM


// CARRIER ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SynthDef("wCarrier", {
	| inbus = 2, out = 0, freq = 440, carPartial = 1, index = 3, mul = 0.2,
	speed = 1, env =#[10,0,1,10], gate = 1, da=2, amp=1, res=100, resSend = 0.0, rev = 0.0 |
	var mod, car, envelope;

	mod = In.ar(inbus, 1);
	o = SinOsc.ar((freq * carPartial) + mod, 0, mul);

	envelope = EnvGen.kr(Env.adsr(*env),gate, doneAction: da);

	//o = BLowPass.ar(o,freq*5,1,2); // ANVÄND LOW PASS FÖR ATT FILTRERA BORT HÖGA GREJER OCH LÅT DET SEDAN KOMMA IN I CRAZY PASSAGER

	o = FoaEncode.ar(o,FoaEncoderMatrix.newOmni);
	o = FoaTransform.ar(o,'focus',pi/2,LFSaw.ar(0.1*speed,mul: pi));

	o = o * envelope * amp;
	//Out.ar(res, Mix.ar(o*resSend));
	//o = FoaDecode.ar(o,~decoder);
	Out.ar(~reverbSend, o*rev);
	Out.ar(out, o )
}).add;



// MODULATOR ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SynthDef("wModulator", { arg outbus = 2, freq, modPartial = 1, index = 3, mul = 1, env=#[10,0,1,10],
	gate = 1, data= #[0.8,0.8],iespeed =1, ieamm = 10;
	var envelope, indexx;
	envelope = EnvGen.kr(Env.adsr(*env),gate, doneAction: 2);

	indexx = EnvGen.kr(Env.circle(LinLin.kr(data,0.8,1.0,0,ieamm),(data/4)*iespeed,[-5, 0, -5]));
	o = SinOsc.ar(freq * modPartial, 0, freq) *
	//LFNoise1.kr(Rand(3, 6).reciprocal,1,1).abs	*
	(index + indexx);
	o = (o * mul) * envelope;
	Out.ar( outbus, o * mul);
}).add;


~pDcm = { |data, oct=2, bus=60, mod=1, ix=3, mp=1, cp=1, st=3, deg= 0,amp=1, env =#[10,0,1,10]|

	Pchain(
		Pbind(	\group, ~groups[2]	),
		Ppar(
			st.collect{ | iter |
				Ppar(
					data.collect{ |i, n|
						Pmono(*[
							\wModulator,
							//octave: 1,
							freq: (~root.(data)+(oct*12)).midicps*(1+(data[i]*i)),
							//degree: [0,7,11,14,16,18,19s].at(i),
							scale: ~scaleBuilder.(data),
							root: ~root.(data),
							addAction: 0,
							outbus: bus+(iter),
							modPartial: mp*n+iter,
							index: i*(ix/20), //*data[i]),
							mul: 2 - (0.2*n),
							//dur: Pseq([dura],1)
							env: [env],
						])
					}	++	[
						Pmono(*[
							\wCarrier,
							octave: oct,
							data: [data],
							root: ~root.(data),
							addAction: 1,
							inbus: bus+(iter),
							carPartial: cp*data.sum/7+iter,
							index: ix/2,
							speed: (1*data.sum/7*iter),
							amp: amp,
							da: 2,
							env: [env],
							resSend: 0.0;
							//dur: Pseq([dura],1),
				])])
		})
	)
};
//~data = 7.collect( { 1-0.02.rand } );
//~pDcm.(~data, 2, 60, ix: 20, mp:1, cp: 1, st: 3,env: [30,0,0,30]).play;
// ~pDcm.(~data, 4.5, 64, ix: 10, mp:1, cp: 1, st: 3, amp:0.2).play





~pFM = { arg data, octave=4, bus = 70, mod = 1, amm = 1, index= 0, mp =1, cp=1, st =1, deg = 0, fdeg=12, iespeed=0, ieamm = 0, env = #[0,1,0.8,1], amp = 2, dur = 1;
	Ppar([
		Pbind(*[
			instrument: \wModulator,
			root: ~root.(data),
			addAction: 0,
			modPartial: mp,
			index: index,
			ctranspose: fdeg,
			mul: 1 - (0.2),
			data: [data],
			iespeed: dur+env[3],
			ieamm: ieamm,
			outbus: bus,
			group: ~groups[1]
		])]
		++	[
			Pbind(*[
				instrument: \wCarrier,
				root: ~root.(data),
				addAction: 1,
				carPartial: cp,
				index: index/2,
				speed: 1,
				inbus: bus,
				da: 2,
				amp: amp,
				group: ~groups[1]
	])],1)
};



~pFMo = {arg data, octave=4, bus = 70, mod = 1, amm = 1, index= 0, mp =1, cp=1, st =1, deg = 0, fdeg=12, iespeed=0, ieamm = 0, env = #[0,1,0.8,1], amp=2, dur = 1;
	Ppar([
		PmonoArtic(*[
			\wModulator,
			root: ~root.(data),
			addAction: 0,
			modPartial: mp,
			index: index,
			ctranspose: fdeg,
			mul: 1 - (0.2),
			data: [data],
			iespeed: dur+env[3],
			ieamm: ieamm,
			outbus: bus,
			group: ~groups[1],
			env: [env],
		])]
		++	[
			PmonoArtic(*[
				\wCarrier,
				root: ~root.(data),
				addAction: 1,
				carPartial: cp,
				index: index/2,
				speed: 1,
				inbus: bus,
				da: 2,
				group: ~groups[1],
				env: [env],
				amp: amp,
	])],1)
};



~playDRONEFM = { |out=0,le=16,dec=1|
	var d;

	d = Array.fill(6);
	d[0] = { ~pDcm.(~data, 2,	60, ix: 5,  mp:1, cp: 1, st: 2, amp: 1.5, env: [30,0,1,30]) };
	d[1] = { ~pDcm.(~data, 3.5, 64, ix: 1,	mp:2, cp: 2, st: 2, amp: 0.5, env: [30,0,1,30])};
	d[2] = { ~pDcm.(~data, 5,	61, ix: 1,	mp:5, cp: 1, st: 1, amp: 0.5, env: [30,0,1,30]) };
	d[3] = { ~pDcm.(~data, 1,	61, ix: 5,	mp:1, cp: 1, st: 1, amp: 1, env: [30,0,1,30]) };
	d[4] = { ~pDcm.(~data, 5,	64, ix: 10, mp:~root.(), cp: 1, st: 2, amp: 0.1, env: [30,0,1,30]) };
	d[5] = { ~pDcm.(~data, 6,	64, ix: 5,	mp:~root.(), cp: 1, st: 2, amp: 0.1, env: [30,0,1,30])  };

	//d = d.rotate(~root.());

	Ptpar(
		d.collect {|i,n| 	[le*n, Psync(d[n].(),4,le*dec)] }.flatten ++
		d.collect {|i,n|    [(le*n)+(le*d.size), Psync(d[n].()<>~tn.(),4,le*dec)]}.flatten ++
		[le*2.5, Psync(~ping.(5,7,a: 0.2,flt:400)<>~chordSeq.(le*2,0.75)<>~tn.(0),4,d.size*2*le)]
		,inf)<>(out: out, rev: 1);
};


//~pFM.(data: ~data).play


~arpFM = {|stp = 4,i=1|
	var thing, pArp;
	/*
	thing = {
	Pbind(
	\index,		Pseq(4.collect{[0, 2*i, 4*i, 7*i].scramble}.flat));
	};*/

	pArp = { | oct = 2, legato = 1 |

		Pbind(
			//\degree,        Pseq(stp.collect{[0, 2, 4, 7].scramble}.flat),
			//\mtranspose,	Pseq(stp.collect{[0, 2, 4, 7].scramble}.flat),
			\dur, 			Pn(Pseq(((stp*2).collect{1/stp} ++ (stp*4).collect{1/(stp*2)}).scramble),inf,\step),
			\octave,		oct,
			//\scale, 		~scaleBuilder.(data),//[0, 2, 3, 5, 7, 9, 10],
			//\root,          ~root.(data),
			\env,           [[0.01,0.1,0.2,0.5]],
			\legato, 1/4,
			\index,		Pseq(4.collect{[0, 2*i, 4*i, 7*i].scramble}.flat,inf)
		)
	};
	/*
	o = Pfsm([
	#[3,4,5,6,7], // entry states

	//e1 (== state 0)
	Pchain(thing.(1),pArp.(5,2)),
	#[1, 1, 3, 1, 1, 1, 1, 4],

	//e2 (== state 1)
	Pchain(thing.(0),pArp.(7,2)),
	#[0, 1],

	//e3 (== state 2)
	Pchain(thing.(1),pArp.(5,2)),
	#[0, 1, 2, 2, 2, 2, 3, 3, 3, 3],

	//e4 (== state 3)
	Pchain(thing.(10),pArp.(4,2)),
	#[4, 4, 4, 6, 6],

	//e5 (== state 4)
	Pchain(thing.(0.5),pArp.(3,2)),
	#[2, 3],

	//e6 (== state 5)
	Pchain(thing.(0),pArp.(5,2)),
	#[0, 2, 4, 5, 5, 5, 5, 5, 5, 5],

	//e7 (== state 6)
	Pchain(thing.(3),pArp.(6,2)),
	#[4, 4, 4, 4, 6, 6, 6, 7, 7, 7],

	//e8 (== state 7)
	Pchain(thing.(200),pArp.(5,2)),
	#[1, 3, 6, 6, 6],

	// terminal state
	nil, nil
	]);
	*/
	pArp.(4);
};

/*
(
~data = 7.collect( { 1-0.2.rand } );
//Pchain(	~pFM.(data: ~data, ieamm: 20, fdeg: 0), ~arpFM.(~data) ).play;
Pchain(	Pn(~pDrone2cm.(data: ~data, octave: 2, index: 2, amm: ~data, deg: 0, st: 3)), ~arpu.() ).play
)
*/