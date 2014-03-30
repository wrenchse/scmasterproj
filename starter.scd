(
s.makeGui;
s.meter;
s.plotTree;
)

(
s.freeAll;
~seed = 12;
"Reverb.scd".resolveRelative.load;
"pingupingu.scd".resolveRelative.load;
"scalebuilder.scd".resolveRelative.load;
"rutiner.scd".resolveRelative.load;
)



"rutiner.scd".resolveRelative.load;

~spelaspela = Ptpar([0, ~melodi, 0, Pchain(~meta1,	Ptpar([16, ~bas, 0, ~arp, 8, ~arp2, 16, ~chords]))]).play;
~spelaspela.stop;


~data = 7.collect( { 1-0.1.rand } );
Synth.new(\wrenchVerb, [\vol, 1]);







// ***************************************************************************** //




MIDIIn.connectAll;


(
~synths = ();
MIDIdef.noteOn(\noteOnAction, {|vel, num|
~synths[num] = Synth(\pinguPingu, [
\freq, num.midicps,
\mod, 1,
] 	++ ~pinguPresets.at(6)
	);
});
MIDIdef.noteOff(\noteOffAction, {|vel, num|
~synths[num].set(\gate, 0);
});
)



