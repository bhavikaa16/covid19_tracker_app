package com.example.covid_tracker

import android.telephony.SmsManager
import android.util.Log

class SmsService {
    fun sendSMS(phoneNumber: String, message: String) {
        try {
            val smsManager = SmsManager.getDefault()
            smsManager.sendTextMessage(phoneNumber, null, message, null, null)
            Log.d("SmsService", "SMS sent to $phoneNumber")
        } catch (e: Exception) {
            Log.e("SmsService", "Failed to send SMS", e)
        }
    }
}
