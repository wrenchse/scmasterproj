




(
Synth.new(\wrenchVerb, [\vol, 1]);
//Synth.new(\reson, [\pitches, 0]);
)


(
SynthDef(\droneWrench, { |
	out		=	0, 		freq 	=	60,		mod	=	0.2,
	revLev 	=	0.5,	resLev 	=	0,		amp	=	1,
	gate 	= 	1,		deviat	=	1.0, 	data = #[1,1,1,1,1,1,1],
	env 	= #[10,	0.1,	1,		10]		|

	var drone1, drone2, freq1 = freq, sound, envelope, phase, summa;

	phase = LinLin.kr(data.sum/7,0.8,1.0,pi/2,-pi/2);
	summa = abs(LinLin.kr(data.sum/7, 0.9, 1.0,0,10));
	envelope = EnvGen.kr(Env.adsr(*env),gate, doneAction: 2);

	drone1 = 4.collect{
		arg i;
		var a;
		a =[
			SinOscFB.ar(
				freq1,
				SinOsc.kr(0.09*data[i]/summa,	summa-phase*data[i],mod*(2*data[i]),1),
				0.4/(i+1*data[i])),
			SinOscFB.ar(
				freq1*2,
				SinOsc.kr(0.05*(i+1/data.sum)*(deviat*10), phase*data[i]*2,mod*2*deviat,1),
				0.2/(i+1)/5)];

		freq1 = freq1 * 2;
		a;
	};

	freq1 = freq * 2;

	drone2 = 4.collect {
		arg i;
		freq1 = freq1 * 2;
		Resonz.ar(
			[PMOsc.ar(freq1/2*(data[i]), freq1/2*SinOsc.kr(0.01,0,0.01,1),summa)*0.1/(i+1),
				PMOsc.ar(freq1/2*(data[i]), freq1*1.5*SinOsc.kr(0.1,0,0.1,1),summa*data[i])*0.5/(i+1)],
			[(1..3)*freq*summa],
			0.3,summa*data[i])
	};

	drone1 = FoaEncode.ar(drone1, FoaEncoderMatrix.newPanto);
	drone1 = FoaTransform.ar(drone1,
		'rotate',LFSaw.ar(0.1,mul: pi, iphase: summa/5));

	drone2 = FoaEncode.ar(drone2, FoaEncoderMatrix.newPanto);
	drone2 = FoaTransform.ar(drone2,
		'rotate',LFSaw.ar(0.1,mul: -pi, iphase: summa/5));

	sound = (drone1+drone2)*envelope;
	sound = FoaDecode.ar(sound, ~decoder);

	Out.ar(out, sound*amp);

	//Out.ar(20, d*0);

	Out.ar(~reverbSend, (sound*1)*revLev);

}).add;
)


MIDIIn.connectAll;


(
~synths = ();
MIDIdef.noteOn(\noteOnAction, {|vel, num|
	~synths[num] = Synth(\droneWrench, [
		\freq, num.midicps,
		\mod, 0.4,
		\deviat, ~dev,
		\data, [~data],
		\env, [20,0,1,2]
	]);
});
MIDIdef.noteOff(\noteOffAction, {|vel, num|
	~synths[num].set(\gate, 0);
});
)


(

~dev = ~data.sum/7;
)

[0,4,9,1].sort

-pi/2.sin




(
~data = 7.collect( { 1-0.1.rand } );

~pDrone = { arg dur = 60, data, octave;
	Pbind(*[
		instrument: \droneWrench,
		dur: dur,
		octave: octave,
		data: [data],
		root: ~root.(data),
/*		group: ~sG*/
	])
};
//~pDrone.(dur: 60, data: ~data, octave: 2).play;
)


(
p = Pspawn(Pbind(
	// Pbind returned by Pfunc is not embedded, just placed in the event
	// So, it can be spawned
	\pattern, ~pDrone.(dur: 10, data: ~data, octave: Pseq([1,2]));,
	\dur, 5,
	\method, \par,
/*	\target, ~sG*/
)).play;
)

p.stop









//////////////////////////////////////////////////////////////////////////////////////////////////////
// FM FM FM FM FM FM FM FM FM FM FM FM FM FM FM FM
// Dividing the "fm" synth def into two pieces, a synthdef for a modulator and a synthdef for the carrier, gives more functionality - carrier signals can shaped by two or more modulators.
// index values usually are between 0 and 24 ---- carPartial :: modPartial => car/mod ratio
(

// CARRIER ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SynthDef("wCarrier", { arg inbus = 2, outbus = 0, freq = 440, carPartial = 1, index = 3, mul = 0.2, speed = 1;
	var mod, car;

	mod = In.ar(inbus, 1);
	o = SinOsc.ar((freq * carPartial) + mod, 0, mul);

	//o = BLowPass.ar(o,freq*5,1,2); // ANVÄND LOW PASS FÖR ATT FILTRERA BORT HÖGA GREJER OCH LÅT DET SEDAN KOMMA IN I CRAZY PASSAGER

	o = FoaEncode.ar(o,FoaEncoderMatrix.newOmni);
	o = FoaTransform.ar(o,'focus',pi/4,LFSaw.ar(0.1*speed,mul: pi));
	o = FoaDecode.ar(o,~decoder, 0.7);

	Out.ar(~reverbSend, o);
	Out.ar(0, o )
}).add;


// MODULATOR ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SynthDef("wModulator", { arg outbus = 2, freq, modPartial = 1, index = 3, mul = 1;

	o = SinOsc.ar(freq * modPartial, 0, freq) *
	LFNoise1.kr(Rand(3, 6).reciprocal,1,1).abs	*
	index;

	Out.ar( outbus, o * mul);
}).add;
)


(
~pDrone2cm = { arg dur = 60, data, octave=2, bus = 62, mod = 1, amm = 1, index= 3, mp =1, cp=1, st =1;
	Ppar(
		st.collect{ | iter |
			Ppar(
				amm.collect{ |i, n|
					Pbind(*[
						instrument: \wModulator,
						dur: dur,
						octave: octave+iter,
						freq: (~root.(data)+(octave*12)).midicps*(1+i),
						root: ~root.(data),
						addAction: 0,
						outbus: bus+(iter*2),
						degree: 0,
						modPartial: mp*n+iter,
						index: 1*n*i+(index/10),
						mul: 1 - (0.2*n)
					])
				}	++	[
					Pbind(*[
						instrument: \wCarrier,
						dur: dur,
						octave: octave,
						data: [data],
						root: ~root.(data),
						addAction: 1,
						inbus: bus+(iter*2),
						degree: 0,
						carPartial: cp*data.sum/7+iter,
						index: index/2,
						speed: (1+iter),
			])],1)
	})
};
)



~data = 7.collect( { 1-0.06.rand } );
~pDrone2cm.(dur: 60, data: ~data, octave: 2, index: 1, amm: ~data, st: 3).play;

(
p = Pspawn(Pbind(
	// Pbind returned by Pfunc is not embedded, just placed in the event
	// So, it can be spawned
	\pattern, ~pDrone2cm.(dur: 10, data: ~data, octave: Pseq([1.,2]));,
	\dur, 5,
	\method, \par,
)).play;
)


