import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_beep_plus/flutter_beep_plus.dart';
import 'package:flutter/material.dart';

class FlutterBeepPlayer {
  static final FlutterBeepPlus _flutterBeepPlusPlugin = FlutterBeepPlus();

  // Lista de sons disponíveis
  static final List<AndroidSoundID> soundsList = [
    AndroidSoundID.TONE_DTMF_0,
    AndroidSoundID.TONE_DTMF_1,
    AndroidSoundID.TONE_DTMF_2,
    AndroidSoundID.TONE_DTMF_3,
    AndroidSoundID.TONE_DTMF_4,
    AndroidSoundID.TONE_DTMF_5,
    AndroidSoundID.TONE_DTMF_6,
    AndroidSoundID.TONE_DTMF_7,
    AndroidSoundID.TONE_DTMF_8,
    AndroidSoundID.TONE_DTMF_9,
    AndroidSoundID.TONE_DTMF_A,
    AndroidSoundID.TONE_DTMF_B,
    AndroidSoundID.TONE_DTMF_C,
    AndroidSoundID.TONE_DTMF_D,
    AndroidSoundID.TONE_SUP_DIAL,
    AndroidSoundID.TONE_SUP_BUSY,
    AndroidSoundID.TONE_SUP_CONGESTION,
    AndroidSoundID.TONE_SUP_RADIO_ACK,
    AndroidSoundID.TONE_SUP_RADIO_NOTAVAIL,
    AndroidSoundID.TONE_SUP_ERROR,
    AndroidSoundID.TONE_SUP_CALL_WAITING,
    AndroidSoundID.TONE_SUP_RINGTONE,
    AndroidSoundID.TONE_PROP_BEEP,
    AndroidSoundID.TONE_PROP_ACK,
    AndroidSoundID.TONE_PROP_NACK,
    AndroidSoundID.TONE_PROP_PROMPT,
    AndroidSoundID.TONE_PROP_BEEP2,
    AndroidSoundID.TONE_SUP_INTERCEPT,
    AndroidSoundID.TONE_SUP_INTERCEPT_ABBREV,
    AndroidSoundID.TONE_SUP_CONGESTION_ABBREV,
    AndroidSoundID.TONE_SUP_CONFIRM,
    AndroidSoundID.TONE_SUP_PIP,
    AndroidSoundID.TONE_CDMA_DIAL_TONE_LITE,
    AndroidSoundID.TONE_CDMA_NETWORK_USA_RINGBACK,
    AndroidSoundID.TONE_CDMA_INTERCEPT,
    AndroidSoundID.TONE_CDMA_ABBR_INTERCEPT,
    AndroidSoundID.TONE_CDMA_REORDER,
    AndroidSoundID.TONE_CDMA_ABBR_REORDER,
    AndroidSoundID.TONE_CDMA_NETWORK_BUSY,
    AndroidSoundID.TONE_CDMA_CONFIRM,
    AndroidSoundID.TONE_CDMA_ANSWER,
    AndroidSoundID.TONE_CDMA_NETWORK_CALLWAITING,
    AndroidSoundID.TONE_CDMA_PIP,
    AndroidSoundID.TONE_CDMA_CALL_SIGNAL_ISDN_NORMAL,
    AndroidSoundID.TONE_CDMA_CALL_SIGNAL_ISDN_INTERGROUP,
    AndroidSoundID.TONE_CDMA_CALL_SIGNAL_ISDN_SP_PRI,
    AndroidSoundID.TONE_CDMA_CALL_SIGNAL_ISDN_PAT3,
    AndroidSoundID.TONE_CDMA_CALL_SIGNAL_ISDN_PING_RING,
    AndroidSoundID.TONE_CDMA_CALL_SIGNAL_ISDN_PAT5,
    AndroidSoundID.TONE_CDMA_CALL_SIGNAL_ISDN_PAT6,
    AndroidSoundID.TONE_CDMA_CALL_SIGNAL_ISDN_PAT7,
    AndroidSoundID.TONE_CDMA_HIGH_L,
    AndroidSoundID.TONE_CDMA_MED_L,
    AndroidSoundID.TONE_CDMA_LOW_L,
    AndroidSoundID.TONE_CDMA_HIGH_SS,
    AndroidSoundID.TONE_CDMA_MED_SS,
    AndroidSoundID.TONE_CDMA_LOW_SS,
    AndroidSoundID.TONE_CDMA_HIGH_SSL,
    AndroidSoundID.TONE_CDMA_MED_SSL,
    AndroidSoundID.TONE_CDMA_LOW_SSL,
    AndroidSoundID.TONE_CDMA_HIGH_SS_2,
    AndroidSoundID.TONE_CDMA_MED_SS_2,
    AndroidSoundID.TONE_CDMA_LOW_SS_2,
    AndroidSoundID.TONE_CDMA_HIGH_SLS,
    AndroidSoundID.TONE_CDMA_MED_SLS,
    AndroidSoundID.TONE_CDMA_LOW_SLS,
    AndroidSoundID.TONE_CDMA_HIGH_S_X4,
    AndroidSoundID.TONE_CDMA_MED_S_X4,
    AndroidSoundID.TONE_CDMA_LOW_S_X4,
    AndroidSoundID.TONE_CDMA_HIGH_PBX_L,
    AndroidSoundID.TONE_CDMA_MED_PBX_L,
    AndroidSoundID.TONE_CDMA_LOW_PBX_L,
    AndroidSoundID.TONE_CDMA_HIGH_PBX_SS,
    AndroidSoundID.TONE_CDMA_MED_PBX_SS,
    AndroidSoundID.TONE_CDMA_LOW_PBX_SS,
    AndroidSoundID.TONE_CDMA_HIGH_PBX_SSL,
    AndroidSoundID.TONE_CDMA_MED_PBX_SSL,
    AndroidSoundID.TONE_CDMA_LOW_PBX_SSL,
    AndroidSoundID.TONE_CDMA_HIGH_PBX_SLS,
    AndroidSoundID.TONE_CDMA_MED_PBX_SLS,
    AndroidSoundID.TONE_CDMA_LOW_PBX_SLS,
    AndroidSoundID.TONE_CDMA_HIGH_PBX_S_X4,
    AndroidSoundID.TONE_CDMA_MED_PBX_S_X4,
    AndroidSoundID.TONE_CDMA_LOW_PBX_S_X4,
    AndroidSoundID.TONE_CDMA_ALERT_NETWORK_LITE,
    AndroidSoundID.TONE_CDMA_ALERT_AUTOREDIAL_LITE,
    AndroidSoundID.TONE_CDMA_ONE_MIN_BEEP,
    AndroidSoundID.TONE_CDMA_KEYPAD_VOLUME_KEY_LITE,
    AndroidSoundID.TONE_CDMA_PRESSHOLDKEY_LITE,
    AndroidSoundID.TONE_CDMA_ALERT_INCALL_LITE,
    AndroidSoundID.TONE_CDMA_EMERGENCY_RINGBACK,
    AndroidSoundID.TONE_CDMA_ALERT_CALL_GUARD,
    AndroidSoundID.TONE_CDMA_SOFT_ERROR_LITE,
    AndroidSoundID.TONE_CDMA_CALLDROP_LITE,
    AndroidSoundID.TONE_CDMA_NETWORK_BUSY_ONE_SHOT,
    AndroidSoundID.TONE_CDMA_ABBR_ALERT,
    AndroidSoundID.TONE_CDMA_SIGNAL_OFF,
  ];

  /// **Método para tocar um som**
  static Future<void> playSound(
      {required int soundIndex, required int duration}) async {
    try {
      if (soundIndex < 0 || soundIndex >= soundsList.length) {
        debugPrint("Índice de som inválido: $soundIndex");
        return;
      }

      // Toca o som
      await _flutterBeepPlusPlugin.playSysSound(soundsList[soundIndex]);
      debugPrint("Tocando som: ${soundsList[soundIndex]}");

      // Aguarda o tempo definido antes de parar
      await Future.delayed(Duration(milliseconds: duration));

      // Para o som
      await _flutterBeepPlusPlugin.stopSysSound();
      debugPrint("Som parado após $duration ms.");
    } catch (e) {
      debugPrint("Erro ao tocar o som: $e");
    }
  }

  /// **Método para tocar todos os sons da lista**
  static Future<void> playAllSounds(int duration) async {
    try {
      for (var sound in soundsList) {
        // Toca o som
        await _flutterBeepPlusPlugin.playSysSound(sound);
        if (kDebugMode) {
            print("Tocando som: $sound");
          }

        // Aguarda o tempo definido antes de passar para o próximo som
        await Future.delayed(Duration(milliseconds: duration));

        // Para o som
        await _flutterBeepPlusPlugin.stopSysSound();
        debugPrint("Som parado após $duration ms.");
      }
    } catch (e) {
      debugPrint("Erro ao tocar os sons: $e");
    }
  }
}
