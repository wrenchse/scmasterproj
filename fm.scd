// FM FM FM FM FM FM FM FM FM FM


// CARRIER ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SynthDef("wCarrier", { arg inbus = 2, outbus = 0, freq = 440, carPartial = 1, index = 3, mul = 0.2, speed = 1, env =#[10,0,1,10], gate = 1, da=2;
	var mod, car, envelope;

	mod = In.ar(inbus, 1);
	o = SinOsc.ar((freq * carPartial) + mod, 0, mul);

	envelope = EnvGen.kr(Env.adsr(*env),gate, doneAction: da);

	//o = BLowPass.ar(o,freq*5,1,2); // ANVÄND LOW PASS FÖR ATT FILTRERA BORT HÖGA GREJER OCH LÅT DET SEDAN KOMMA IN I CRAZY PASSAGER

	o = FoaEncode.ar(o,FoaEncoderMatrix.newOmni);
	o = FoaTransform.ar(o,'focus',pi/4,LFSaw.ar(0.1*speed,mul: pi));

	o = o * envelope;

	Out.ar(~reverbSend, o);
	Out.ar(0, o )
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

~pDrone2cm.(dura: 10, data: ~data, octave: 2, index: 2, amm: ~data, deg: 0, st: 3).play

~pDrone2cm = { arg dura = 60, data, octave=2, bus = 62, mod = 1, amm = 1, index= 3, mp =1, cp=1, st =3, deg= 0;
	Pchain(
		Pbind(
			\group, ~groups[2],
			\legato, 1),
		Ppar(
			st.collect{ | iter |
				Ppar(
					amm.collect{ |i, n|
						Pmono(*[
							 \wModulator,
							octave: octave+iter,
							freq: (~root.(data)+(octave*12)).midicps*(1+i),
							root: ~root.(data),
							addAction: 0,
							outbus: bus+(iter),
							modPartial: mp*n+iter,
							//index: 1*n*i+(index/10),
							mul: 1 - (0.2*n),
							//dur: Pseq([dura],1)
						])
					}	++	[
						Pmono(*[
							 \wCarrier,
							octave: octave,
							data: [data],
							root: ~root.(data),
							addAction: 1,
							inbus: bus+(iter),
							degree: deg,
							carPartial: cp*data.sum/7+iter,
							index: index/2,
							speed: (1+iter),
							da: 2,
							//dur: Pseq([dura],1),
				])])
		})
	)
};




~pFM = { arg dur = 1, data, octave=4, bus = 62, mod = 1, amm = 1, index= 0, mp =1, cp=1, st =1, deg = 0, fdeg=12, iespeed=0, ieamm = 10, env = #[0,1,0.8,1];
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
				group: ~groups[1]
	])],1)
};


~pFM.(data: ~data).play
