


//// SCALEBUILDER

(
//~data = [0.96, 0.96, 0.96, 0.95, 1.2, 0.9, 0.96];

~data = 7.collect( { 1-0.2.rand } );

~scaleBuilder = { | data = #[0.96, 0.96, 0.96, 0.95, 1.2, 0.9, 0.96] |
	var varden, rota = 0, bend, tresh = 0.95,
	scale1 = [0, 2, 4, 5, 7, 9, 11], scale2 = [0, 1, 3, 6, 7, 8, 10];

	// ROTERA OM MER ÄN PHI
	varden = data;
	varden.do{ |i|
		if (data[i] > 1, { rota = rota + 1 })
	};
	varden = varden.rotate(rota);

	bend = 1-varden;

	6.do{ |i|
		if (varden[i] < tresh, { scale1[i+1] = scale2[i+1]-(bend[i+1]*2) })
	};

	scale1;
};

~root = {| root = #[1,1,1,1,1,1,1] |
	var offset;
	offset = root.sum/7/9*1000-100;
	offset = (offset.asInt*10) % 12;
};




~melodi2 = 	Pbind(
	\dur, 			0.2,
	\scale, 		~scaleBuilder.value,
	\degree,        Pseq((0..7),1),
	\octave,		4,
	\amp,			0.2,
	\root,          ~root.value,
	\gate, 			1,
	\filtr,			Pwhite(1000,3000),
	\pan, 			Pwhite(-0.1,0.1,inf),
);


)



















