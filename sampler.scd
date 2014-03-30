




~buffers = (Buffer.read(s, "regn2.aiff".resolveRelative));
~buffers = (Buffer.read(s, "strossel1.wav".resolveRelative));
~buffers = (Buffer.read(s, "vass4.wav".resolveRelative));

(
//~resRoutine.play;
//Synth(\reson, [\freq, degree: [2,1,4]]).addToHeadMsg;
x = (instrument: \reson2, dur: 50, scale: ~scaleBuilder.(~data), root: ~root.value, datan: [~data], octave: 4, degree: [-17,-12,0,4,7], group: ~fxG , resSend: 2, revSend: 0.5 ).play;
y = Synth(\samplePlayer,[\out, 0, \buf, ~buffers, \rel, 50.25, \at, 1.0, \rate, -1.02, \datan, ~data], 1 );
r = Synth(\wrenchVerb, target: ~fxG);
)
x.free; y.free; r.free;
"scalebuilder.scd".resolveRelative.load;



Env.circle(LinLin.kr(~data,0.8,1.0,0,1),~data,[-5, 0, -5]).plot;






(
~sampler = {
	arg buffer, dur, datan = [1], grp = 1, atk = dur/4;
	Pbind(*[
		instrument: \samplePlayer,
		buf:		buffer,
		rel:		dur/4,
		at:			atk,
		datan:		[datan],
		group:		grp,
		dur:		Pseq([dur],1)
	])
};

~resonate = {
	arg dur, root, datan, octave = 4,
	chord = [-17,-12,0,4,7], grp = 1, rev = 0.5;
	Pbind(*[
		instrument: \reson2,
		octave: 	octave,
		scale:		~scaleBuilder.(datan),
		root:		~root.(datan),
		degree:		chord,
		datan:		[datan],
		group:		grp,
		dur:		Pseq([dur],1)
	])
}
)

~sampler.(~buffers, dur: 100, datan: ~data).play
~resonate.(dur: 100, datan: ~data).play

~data = 7.collect( { 1-0.2.rand } );


~sampler.stop