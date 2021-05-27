s.options.numInputBusChannels.postln;
~numSamples = 4;
~numChannels = ~numSamples*2;


//DEFINE SAMPLE PATHS
(
~kickSamplePath = "D:/Polidocumenti/Anno 5/CMLS/HW3/Gr8_DrumKit/Samples/Kick.wav";
~clapSamplePath = "D:/Polidocumenti/Anno 5/CMLS/HW3/Gr8_DrumKit/Samples/Clap.wav";
~openHiHatSamplePath = "D:/Polidocumenti/Anno 5/CMLS/HW3/Gr8_DrumKit/Samples/909 OH.wav";
)

//LOAD
(
~kick = Buffer.read(s, ~kickSamplePath);
~clap = Buffer.read(s, ~clapSamplePath);
~openHiHat = Buffer.read(s, ~openHiHatSamplePath);
)

//PLAY
~kick.plot;
~clap.plot;
~openHiHat.plot;

~kick.play;
~openHiHat.play;
~clap.play;







~bus = Bus.audio(s, numChannels);

~loadSample = {
	arg samplePath;
	Buffer.read(s, samplePath);
};

~kick = Buffer.read(s, ~kickSamplePath);
~kick.plot;



