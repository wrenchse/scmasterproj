// PROCESSING UNITS ˙£@±]$[±@∞£˙@∞´∞~±§£ı≈˙µ$œ√¸›ª‹$ß∂ƒ¸‹
(
SynthDef("preDelay", { arg inbus = 100, outbus = 64, time = 0.048;
	ReplaceOut.ar(
		outbus,
		DelayN.ar(In.ar(inbus, 1), time, time)
	)
}).load(s);

SynthDef("combs", { arg inbus = 64, outbus = 66, decay = 15;
	ReplaceOut.ar(
		outbus,
		Mix.fill(7, { CombL.ar(In.ar(inbus, 1), 0.1, LFNoise1.kr(Rand(0, 0.1), 0.04, 0.05), decay) })
	)
}).load(s);


SynthDef("allpass", { arg gain = 0.2, inbus = 66, outbus = 68, decay = 1;
	var source;
	source = In.ar(inbus, 1);
	4.do({ source = AllpassN.ar(source, 0.050, [Rand(0, 0.05), Rand(0, 0.05)], decay) });
	ReplaceOut.ar(
		outbus,
		source * gain
	)
}).load(s);


SynthDef("theMixer", { arg gain = 1, inbus = 68;
	Out.ar(
		0,
		Mix.ar([In.ar(2, 1), In.ar(inbus, 2)]) * gain
	)
}).load(s);

)


//////////////////////////////////////////////////////////////////////////////////////////////////////
// FM FM FM FM FM FM FM FM FM FM FM FM FM FM FM FM
// Dividing the "fm" synth def into two pieces, a synthdef for a modulator and a synthdef for the carrier, gives more functionality - carrier signals can shaped by two or more modulators.
// index values usually are between 0 and 24 ---- carPartial :: modPartial => car/mod ratio
(

// CARRIER ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SynthDef("carrier", { arg inbus = 2, outbus = 0, freq = 440, carPartial = 1, index = 3, mul = 0.2;
	var mod, car;

	mod = In.ar(inbus, 1);
	o = SinOsc.ar((freq * carPartial) + mod, 0, mul);

	//o = BLowPass.ar(o,freq*5,1,2); // ANVÄND LOW PASS FÖR ATT FILTRERA BORT HÖGA GREJER OCH LÅT DET SEDAN KOMMA IN I CRAZY PASSAGER

	Out.ar( outbus, o )
}).load(s);


// MODULATOR ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SynthDef("modulator", { arg outbus = 2, freq, modPartial = 1, index = 3;

	o = SinOsc.ar(freq * modPartial, 0, freq) *
		LFNoise1.kr(Rand(3, 6).reciprocal).abs	*
		index;

	Out.ar( outbus, o );
}).load(s);
)





// -------------------------------------------------------------
// FM PLAY !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
(
var freq = 100;
var modfreq = freq*1.5;
var index = 10;
var mP = 1;
var cP = 0.5;

// modulators for the left channel
Synth.head(s, "modulator", [\outbus, 60, \freq, modfreq, \modPartial, mP, \index, index]);
//Synth.head(s, "modulator", [\outbus, 60, \freq, modfreq, \modPartial, 0.683, \index, 20.31]);

// modulators for the right channel
Synth.head(s, "modulator", [\outbus, 62, \freq, modfreq, \modPartial, mP, \index, index]);
//Synth.head(s, "modulator", [\outbus, 62, \freq, modfreq, \modPartial, 0.683, \index, 20.31]);

// left and right channel carriers
Synth.tail(s, "carrier", [\inbus, 60, \outbus, 100, \freq, freq, \carPartial, cP+0.001]);
Synth.tail(s, "carrier", [\inbus, 62, \outbus, 101, \freq, freq, \carPartial, cP]);


Synth.tail(s, "preDelay", [\inbus, 100, \outbus, 64, \time, 0.048]);

Synth.tail(s, "combs", [\inbus, 64, \outbus, 66, \decay, 0.0]);

Synth.tail(s, "allpass", [\inbus, 66, \outbus, 68, \decay, 0]);

Synth.tail(s, "theMixer", [\inbus, 68, \gain, 1]);
//s.scope;
)


(

s.queryAllNodes;

)


////////////////////////////////////////////////////////////////////////////////////////////////////
