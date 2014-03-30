Ndef(\dynk, {
        var n = 30;
        var freqs = NamedControl(\freqs, { (30 + 75.rand).midicps }.dup(n));
        var amps = NamedControl(\amps, { 0.002 + 0.007.rand }.dup(n));
        var ringtimes = NamedControl(\ringtimes, { 0.05 + 0.25.rand }.dup(n));

        DynKlank.ar([`[freqs, amps, ringtimes], `[freqs, amps,
ringtimes]], WhiteNoise.ar(0.001.dup))
});

// play to the main outputs
Ndef(\dynk).play;

// set the params after the synth is running:
Ndef(\dynk).setn(\freqs, { (30 + 75.rand).midicps }.dup(30));
Ndef(\dynk).setn(\amps, { 0.002 + 0.007.rand }.dup(30));
Ndef(\dynk).setn(\ringtimes, { 0.05 + 0.25.rand }.dup(30));

// the last settings are stored here
Ndef(\dynk).getKeysValues;

// xfade to a new copy of the synth process,
// with a new setting for freqs
Ndef(\dynk).fadeTime = 10;
Ndef(\dynk).xsetn(\freqs, { (30 + 75.rand).midicps }.dup(30));


s.plotTree