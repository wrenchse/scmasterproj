
Buffer.freeAll

(
~buffers = Array.fill(7);
~buffers[0] = (Buffer.read(s, "vass4.wav".resolveRelative));
~buffers[1] = (Buffer.read(s, "regn2.aiff".resolveRelative));
~buffers[2] = (Buffer.read(s, "strossel1.wav".resolveRelative));
~buffers[3] = (Buffer.read(s, "kottekras.wav".resolveRelative));
~buffers[4] = (Buffer.read(s, "tandstick.wav".resolveRelative));
~buffers[5] = (Buffer.read(s, "pappersriv.wav".resolveRelative));
~buffers[6] = (Buffer.read(s, "tunna1.wav".resolveRelative));
)
(
~buf = Array.fill(~buffers.size);
~buf[0] = [\buf, ~buffers[0], \amp, 2];
~buf[1] = [\buf, ~buffers[1], \amp, 1];
~buf[2] = [\buf, ~buffers[2], \amp, 0.3];
~buf[3] = [\buf, ~buffers[3], \amp, 0.4];
~buf[4] = [\buf, ~buffers[4], \amp, 0.6];
~buf[5] = [\buf, ~buffers[5], \amp, 0.6];
~buf[6] = [\buf, ~buffers[6], \amp, 0.6];

~sampler = {
	arg buffer, dur=60, f = 10;
	Pbind(*([
		instrument: \samplePlayer,
		rel:		f,
		at:			f,
		datan:		[~data],
		group:		~groups[5],
		resSend: 	1,
	]++ ~buf.at(buffer)))
};

~resonate = {
	arg datan, octave = 5;
	Pbind(*[
		instrument: \reson2,
		octave: 	octave,
		datan:		[datan],
		group:		~groups[6],
		fb: 0.9,
	])
}
)

~data = 7.collect( { 1-0.2.rand } );

(~sampler.(3, datan: ~data)<>(dur:100)).play
(~resonate.(~data)<>~chord3.(1,7)<>~arpFM.()<>~tn.(~data)).play

(~resonate.(~data)<>~chordSeq.(10,0.5)<>~tn.(~data,0)).play

(
(~pFMo.(~data,ieamm:0.2)<>Pstutter(2,~chord3.([1],7,arp:1))<>~arpFM.(4,5,3)<>~tn.(~data)).play;
(~pFMo.(~data,ieamm:0.2)<>Pstutter(1,~chord3.([1],7,arp:1))<>~arpFM.(4,3,3)<>~tn.(~data)).play
)

~testArpFM = {|st=4,stutter=2,i=1|
	~pFMo.(~data,ieamm:0.2)<>Pstutter(stutter,~chord3.([1],7,arp:1))<>~arpFM.(st,i)
}


~testArpFM.(3).play

(
~parts3 = {|d,le=16,dec=2|
	Pspawn(
		Pbind(
			\pattern, { Psync(~testArpFM.([1,2,3].choose,[1,2].choose,[1,2,3].choose),4,le*dec) },
			    \delta, le,
			    \method, Pseq([\par,Prand([\par,\wait],1)],inf),
		)
	)
};
)

(~parts3.(d,4,2)<>~tn.(~data)).play;

[8,9].choose



























Env.circle(LinLin.kr(~data,0.8,1.0,0,1),~data,[-5, 0, -5]).plot;
