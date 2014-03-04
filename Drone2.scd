




(
Synth.new(\wrenchVerb, [\vol, 1]);
//Synth.new(\reson, [\pitches, 0]);
)


(
SynthDef(\droneWrench, { |
	out		=	0, 		freq 	=	60,		mod	=	0.2,
	revLev 	=	0.5,	resLev 	=	0,		amp	=	1,
	gate 	= 	1										|

	var drone1, drone2, freq1 = freq, sound, env;

	env = EnvGen.kr(Env.adsr(2,0,1,4),gate, doneAction: 2);

	drone1 = 4.collect{
		arg i;
		freq1 = freq1 * 2;
		[SinOscFB.ar(freq1/1.5, SinOsc.kr(0.04*(i+1)/5,-1,mod,1),0.3/(i+1)/3),
			SinOscFB.ar(freq1, SinOsc.kr(0.02*(i+1/5),-1,mod,1),0.3/(i+1)/5)]
	};

	freq1 = freq * 2;

	drone2 = 4.collect {
		arg i;
		freq1 = freq1 * 2;
		Resonz.ar(
			[PMOsc.ar(freq1/2, freq1/2*SinOsc.kr(0.01,0,0.01,1),1)*0.1/(i+1),
				PMOsc.ar(freq1/2, freq1*1.5*SinOsc.kr(0.01,0,0.01,1),1)*0.05/(i+1)],
			[(1..4)*freq],
			0.4,5)
	};

	drone1 = FoaEncode.ar(drone1, FoaEncoderMatrix.newPanto);
	drone1 = FoaTransform.ar(drone1,
		'rotate',LFSaw.ar(0.1,mul: pi));

	drone2 = FoaEncode.ar(drone2, FoaEncoderMatrix.newPanto);
	drone2 = FoaTransform.ar(drone2,
		'rotate',LFSaw.ar(0.1,mul: -pi));

	sound = (drone1+drone2)*env;
	sound = FoaDecode.ar(sound, ~decoder);

	Out.ar(out, sound*amp);

	//Out.ar(20, d*0);

	Out.ar(~reverbSend, (sound*1)*revLev);

}).add;
)


(
//Synth.new(\wrenchVerb, [\vol, 1]);
MIDIFunc.noteOn({arg vel, note; y = Synth(\droneWrench, [\freq, note.midicps, \mod, 1] ).postln });
MIDIFunc.noteOff({arg vel, note; y.set(\gate, 0).postln });
)


Synth.new(\wrenchVerb, [\vol, 1]);
(

{y = Synth.new(\droneWrench, [\freq, 16.midicps, \mod, 1, \revLev, 1] )}.play
)

(
Synth.new(\wrenchVerb, [\vol, 1]);
~decoder = FoaDecoderMatrix.newQuad;
)





//////////////////////////////////////////////////////////////////////////////////////////////////////
// FM FM FM FM FM FM FM FM FM FM FM FM FM FM FM FM
// Dividing the "fm" synth def into two pieces, a synthdef for a modulator and a synthdef for the carrier, gives more functionality - carrier signals can shaped by two or more modulators.
// index values usually are between 0 and 24 ---- carPartial :: modPartial => car/mod ratio
(

// CARRIER ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SynthDef("carrier", { arg inbus = 2, outbus = 0, freq = 440, carPartial = 1, index = 3, mul = 0.2, speed = 1;
	var mod, car;

	mod = In.ar(inbus, 1);
	o = SinOsc.ar((freq * carPartial) + mod, 0, mul);

	//o = BLowPass.ar(o,freq*5,1,2); // ANVÄND LOW PASS FÖR ATT FILTRERA BORT HÖGA GREJER OCH LÅT DET SEDAN KOMMA IN I CRAZY PASSAGER

	o = FoaEncode.ar(o,FoaEncoderMatrix.newOmni);
	o = FoaTransform.ar(o,'focus',pi/4,LFSaw.ar(0.1*speed,mul: pi));
	o = FoaDecode.ar(o,~decoder, 0.7);

	Out.ar(~reverbSend, o);
	Out.ar(0, o )
}).load(s);


// MODULATOR ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SynthDef("modulator", { arg outbus = 2, freq, modPartial = 1, index = 3;

	o = SinOsc.ar(freq * modPartial, 0, freq) *
		LFNoise1.kr(Rand(3, 6).reciprocal,1,1).abs	*
		index;

	Out.ar( outbus, o );
}).load(s);
)





// -------------------------------------------------------------
// FM PLAY !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
(
var freq = 50;
var modfreq = freq*1.571;
var index = 4.4;
var mP = 1;
var cP = 0.5;

// modulators for the left channel
Synth.head(s, "modulator", [\outbus, 60, \freq, modfreq, \modPartial, mP, \index, index]);
Synth.head(s, "modulator", [\outbus, 60, \freq, modfreq, \modPartial, 0.683, \index, 20.31]);

// modulators for the right channel
Synth.head(s, "modulator", [\outbus, 62, \freq, modfreq, \modPartial, mP, \index, index]);
Synth.head(s, "modulator", [\outbus, 62, \freq, modfreq, \modPartial, 0.683, \index, 20.31]);

// left and right channel carriers
Synth.tail(s, "carrier", [\inbus, 60, \outbus, 100, \freq, freq, \carPartial, cP+0.001, \speed, 1]);
Synth.tail(s, "carrier", [\inbus, 62, \outbus, 101, \freq, freq, \carPartial, cP, \speed, -1]);


//Synth.tail(s, "preDelay", [\inbus, 100, \outbus, 66, \time, 0.048]);

//Synth.tail(s, "combs", [\inbus, 64, \outbus, 66, \decay, 0.0]);

//Synth.tail(s, "allpass", [\inbus, 66, \outbus, 68, \decay, 0]);

//Synth.tail(s, "theMixer", [\inbus, 68, \gain, 1]);
//s.scope;
)