




(
Synth.new(\wrenchVerb, [\vol, 1]);
//Synth.new(\reson, [\pitches, 0]);
)


(
SynthDef(\droneWrench, { |
	out		=	0, 		freq 	=	60,		mod	=	0.2,
	revLev 	=	0.5,	resLev 	=	0,		amp	=	1,
	gate 	= 	1,		deviat	=	1.0, 	data = #[1,1,1,1,1,1,1]			|

	var drone1, drone2, freq1 = freq, sound, env, phase;

	phase = LinLin.kr(deviat,0.8,1.0,pi/2,-pi/2);
	env = EnvGen.kr(Env.adsr(2,0,1,4),gate, doneAction: 2);

	drone1 = 4.collect{
		arg i;
		var a;
		a =[
			SinOscFB.ar(
				freq1,
				SinOsc.kr(0.09*(i+1)/data.sum,	phase*data[i]+data.sum,mod*(2*data[i]),1),
				0.8/(i+1)*data[i]),
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
			[PMOsc.ar(freq1/2*(data[i]*2), freq1/2*SinOsc.kr(0.01,0,0.01,1),1)*0.1/(i+1),
				PMOsc.ar(freq1/2*(data[i]*2), freq1*1.5*SinOsc.kr(0.1,0,0.1,1),1)*0.5/(i+1)],
			[(1..3)*freq*deviat],
			0.4,5/(i+1)*data[i])
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


MIDIIn.connectAll;


(
~synths = ();
MIDIdef.noteOn(\noteOnAction, {|vel, num|
~synths[num] = Synth(\droneWrench, [
\freq, num.midicps,
\mod, 0.4,
\deviat, ~dev,
\data, [~data]

]);
});
MIDIdef.noteOff(\noteOffAction, {|vel, num|
~synths[num].set(\gate, 0);
});
)



(
~data = 7.collect( { 1-0.1.rand } );
~dev = ~data.sum/7;
)

[0,4,9,1].sort

-pi/2.sin


(
var toner, length;
thisThread.randSeed = 10;

toner = 10.collect{ |i| ~melodyNotes2.().[i] };
length= 10.collect{ |i| ~melodyDur.().flatten[i] };

Ppar( 4.collect{
	arg i;
Pbind(*[
	instrument: \default, //\droneWrench,
		dur: 			Pseq(length,inf),
//		dur: 10-i,
		stretch: 2/(i+1.2),
		degree: Pseq(toner,inf),
		octave: 4,
		scale: ~scaleBuilder.value,
])
}).play
)




(
p = Pspawn(Pbind(
        // Pbind returned by Pfunc is not embedded, just placed in the event
        // So, it can be spawned
	\pattern, Pfunc( ~melodi2.(6,0.2) ),
	\dur, Pseq([1,1.1]),
    \method, \par
)).play;
)


(
~melodi2 = {	arg number = 1, dur = 0.2;
Pbind(
	\dur, 			dur,
	\scale, 		~scaleBuilder.(~data),
	\degree,        Pseq((0..7),1),
	\octave,		number,
	\amp,			0.2,
	\root,          ~root.value,
	\gate, 			1,
	\filtr,			Pwhite(1000,3000),
	\pan, 			Pwhite(-0.1,0.1,inf),
)};
)
(
~melodi2 =
Pbind(
	\dur, 			0.2,
	\scale, 		~scaleBuilder.(~data),
	\degree,        Pseq((0..7),1),
	\octave,		5,
	\amp,			0.2,
	\root,          ~root.value,
	\gate, 			1,
	\filtr,			Pwhite(1000,3000),
	\pan, 			Pwhite(-0.1,0.1,inf),
);
)






~melodi2




"scalebuilder.scd".resolveRelative.load;






~melodyDur.value.flatten[1]










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