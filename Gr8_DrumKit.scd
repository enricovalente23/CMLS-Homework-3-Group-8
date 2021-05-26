s.options.numInputBusChannels.postln;
var numSamples = 4;
var numChannels = numSamples*2;


var kickSamplePath = "D:/Polidocumenti/Anno 5/CMLS/HW3/Gr8_DrumKit/Samples/Kick.wav";
var clapSamplePath = "D:/Polidocumenti/Anno 5/CMLS/HW3/Gr8_DrumKit/Samples/Clap.wav";
var openHiHatSamplePath = "D:/Polidocumenti/Anno 5/CMLS/HW3/Gr8_DrumKit/Samples/Kick.wav";

loadSample = {
	arg samplePath;
	Buffer.read(s, samplePath);
};

~bus = Bus.audio(s, numChannels);

(

var kickSamplePath = "D:/Polidocumenti/Anno 5/CMLS/HW3/Gr8_DrumKit/Samples/Kick.wav";
~kick = loadSample.value(kickSamplePath);
~kick.plot;
)



//RUNNABLE
~kick = Buffer.read(s, "D:/Polidocumenti/Anno 5/CMLS/HW3/Gr8_DrumKit/Samples/Kick.wav");
~kick.plot;
~kick.play;

~clap = Buffer.read(s, "D:/Polidocumenti/Anno 5/CMLS/HW3/Gr8_DrumKit/Samples/Clap.wav");
~clap.plot;
~clap.play;

~openHiHat = Buffer.read(s, "D:/Polidocumenti/Anno 5/CMLS/HW3/Gr8_DrumKit/Samples/Kick.wav");
~openHiHat.plot;
~openHiHat.play;