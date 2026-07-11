import 'dart:math';
import 'dart:typed_data';

class AudioSynthesizer {
  /// Generates a standard WAV file header + PCM data for a sequence of tones
  static Uint8List generateWav({
    required List<double> frequencies,
    required List<double> durations,
    required List<double> volumes,
    int sampleRate = 22050,
  }) {
    int totalSamples = 0;
    for (var d in durations) {
      totalSamples += (d * sampleRate).toInt();
    }

    final dataSize = totalSamples * 2; // 16-bit PCM (2 bytes per sample)
    final wavBytes = Uint8List(44 + dataSize);
    final bd = ByteData.view(wavBytes.buffer);

    // RIFF Header
    wavBytes.setRange(0, 4, 'RIFF'.codeUnits);
    bd.setUint32(4, 36 + dataSize, Endian.little);
    wavBytes.setRange(8, 12, 'WAVE'.codeUnits);

    // fmt subchunk
    wavBytes.setRange(12, 16, 'fmt '.codeUnits);
    bd.setUint32(16, 16, Endian.little);
    bd.setUint16(20, 1, Endian.little); // PCM format
    bd.setUint16(22, 1, Endian.little); // Mono
    bd.setUint32(24, sampleRate, Endian.little);
    bd.setUint32(28, sampleRate * 2, Endian.little); // Byte rate
    bd.setUint16(32, 2, Endian.little); // Block align
    bd.setUint16(34, 16, Endian.little); // Bits per sample

    // data subchunk
    wavBytes.setRange(36, 40, 'data'.codeUnits);
    bd.setUint32(40, dataSize, Endian.little);

    int currentByteOffset = 44;

    for (int note = 0; note < frequencies.length; note++) {
      double freq = frequencies[note];
      double duration = durations[note];
      double volume = volumes[note];
      int noteSamples = (duration * sampleRate).toInt();

      for (int i = 0; i < noteSamples; i++) {
        double t = i / sampleRate;
        double sampleVal = 0.0;

        if (freq > 0) {
          sampleVal = sin(2 * pi * freq * t);
          
          // Apply a gentle fade-in and fade-out envelope to avoid crackles
          double envelope = 1.0;
          double attackTime = 0.008; // 8ms
          double decayTime = 0.015; // 15ms
          if (t < attackTime) {
            envelope = t / attackTime;
          } else if (t > duration - decayTime) {
            envelope = (duration - t) / decayTime;
          }
          sampleVal *= envelope * volume;
        }

        int sampleInt = (sampleVal * 32767).toInt().clamp(-32768, 32767);
        bd.setInt16(currentByteOffset, sampleInt, Endian.little);
        currentByteOffset += 2;
      }
    }

    return wavBytes;
  }

  /// Generates a sliding frequency wave (e.g. a slide down buzzer or slide up swoosh)
  static Uint8List generateSlideWav({
    required double startFreq,
    required double endFreq,
    required double duration,
    required double volume,
    int sampleRate = 22050,
  }) {
    int totalSamples = (duration * sampleRate).toInt();
    final dataSize = totalSamples * 2;
    final wavBytes = Uint8List(44 + dataSize);
    final bd = ByteData.view(wavBytes.buffer);

    // RIFF Header
    wavBytes.setRange(0, 4, 'RIFF'.codeUnits);
    bd.setUint32(4, 36 + dataSize, Endian.little);
    wavBytes.setRange(8, 12, 'WAVE'.codeUnits);

    // fmt subchunk
    wavBytes.setRange(12, 16, 'fmt '.codeUnits);
    bd.setUint32(16, 16, Endian.little);
    bd.setUint16(20, 1, Endian.little);
    bd.setUint16(22, 1, Endian.little);
    bd.setUint32(24, sampleRate, Endian.little);
    bd.setUint32(28, sampleRate * 2, Endian.little);
    bd.setUint16(32, 2, Endian.little);
    bd.setUint16(34, 16, Endian.little);

    // data subchunk
    wavBytes.setRange(36, 40, 'data'.codeUnits);
    bd.setUint32(40, dataSize, Endian.little);

    int currentByteOffset = 44;
    for (int i = 0; i < totalSamples; i++) {
      double pct = i / totalSamples;
      double t = i / sampleRate;

      // Correct integration of frequency over time for constant slide:
      // f(t) = startFreq + slope * t where slope = (endFreq - startFreq) / duration
      // Phase integral is 2 * pi * (startFreq * t + 0.5 * slope * t^2)
      double slope = (endFreq - startFreq) / duration;
      double phase = 2 * pi * (startFreq * t + 0.5 * slope * t * t);
      double sampleVal = sin(phase);

      // Volume envelope with exponential decay
      double envelope = exp(-3.0 * pct); // Decays nicely
      if (t < 0.005) { // 5ms quick attack
        envelope *= (t / 0.005);
      }
      sampleVal *= envelope * volume;

      int sampleInt = (sampleVal * 32767).toInt().clamp(-32768, 32767);
      bd.setInt16(currentByteOffset, sampleInt, Endian.little);
      currentByteOffset += 2;
    }

    return wavBytes;
  }
}
