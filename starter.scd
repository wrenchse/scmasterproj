
s.plotTree;

(
s.freeAll;
~seed = 12;
"boot.scd".resolveRelative.load;
"pingupingu.scd".resolveRelative.load;
"scalebuilder.scd".resolveRelative.load;
"rutiner.scd".resolveRelative.load;
"fm.scd".resolveRelative.load;
"metafys.scd".resolveRelative.load;
)


p = ~pMetafyx.(data: ~data, vol: 0.5, mix: -1, len: 10,  smear: 0.7, lpf: 10000, resS: 1, dist: 2, dmix: -1).play;

p = ~pMetafyx.(data: ~data, vol: 0.5, mix: -1, len: 10,  smear: 0.7, lpf: 10000, resS: 1, dist: 2, dmix: -1).play;



(

o = OSCFunc({| msg |
	Synth(\snare);
		~data = msg;
	~data.removeAt(0);
	~playIt = ~pMetafyx.(data: ~data, vol: 0.4, mix: -1, len: 1,  smear: 0.2, lpf: 10000, resS: 1, dist: 2, dmix: -1 ).play;
}, '/start'); // create the OSCresponderNode

p = OSCFunc({| msg |
	Synth(\kick);
	~playIt.stop;
}, '/gui'); // create the OSCresponderNode

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



