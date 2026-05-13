package com.example.testing_project;

import android.Manifest;
import android.content.pm.PackageManager;
import android.net.wifi.ScanResult;
import android.net.wifi.WifiConfiguration;
import android.net.wifi.WifiManager;
import android.net.wifi.WifiNetworkSuggestion;
import android.os.Build;
import android.net.MacAddress;
import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import android.content.Intent;
import android.location.LocationManager;
import android.provider.Settings;

import android.net.wifi.WifiEnterpriseConfig;
import java.security.cert.X509Certificate;
import java.util.Arrays;
import java.math.BigInteger;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.util.Date;
import java.lang.reflect.Method;
import java.lang.reflect.Field;

import javax.security.auth.x500.X500Principal;
import java.security.cert.CertificateFactory;
import java.io.ByteArrayInputStream;
import java.security.MessageDigest;

import java.io.ByteArrayInputStream;
import java.security.KeyStore;
import java.security.cert.Certificate;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.util.Enumeration;
import javax.net.ssl.TrustManager;
import javax.net.ssl.TrustManagerFactory;
import javax.net.ssl.X509TrustManager;
import android.util.Base64;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.testing_project/wifi_control";
    private static final int PERMISSION_REQUEST_CODE = 1001;
    private MethodChannel.Result pendingResult;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    try {
                        switch (call.method) {
                            case "askWifiPermissions":
                                askWifiPermissions(result);
                                break;
                            case "getWifiScanResults":
                                getWifiScanResults(result);
                                break;
                            case "connectToWifi":
                                String ssid = call.argument("ssid");
                                String password = call.argument("password");
                                String securityType = call.argument("securityType");
                                String bssid = call.argument("bssid"); // Add BSSID parameter
                                connectToWifi(ssid, password, securityType, bssid, result);
                                break;// New parameter
                    
                            default:

                                result.notImplemented();
                        }
                    } catch (Exception e) {
                        result.error("NATIVE_ERROR", e.getMessage(), null);
                    }
                });
    }

    // Existing permission methods remain the same...
    private void askWifiPermissions(MethodChannel.Result result) {
        try {
            List<String> permissions = new ArrayList<>();

            if (ActivityCompat.checkSelfPermission(this,
                    Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                permissions.add(Manifest.permission.ACCESS_FINE_LOCATION);
            }


            if (!permissions.isEmpty()) {
                pendingResult = result;
                ActivityCompat.requestPermissions(this,
                        permissions.toArray(new String[0]),
                        PERMISSION_REQUEST_CODE);
            } else {
                if (!isLocationEnabled()) {
                    askUserToEnableLocation();
                    result.success(false);
                } else if (!isWifiEnabled()) {
                    askUserToEnableWifi();
                    result.success(false);
                } else {
                    result.success(true);
                }
            }
        } catch (Exception e) {
            result.error("PERMISSION_ERROR", e.getMessage(), null);
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode,
            @NonNull String[] permissions,
            @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == PERMISSION_REQUEST_CODE && pendingResult != null) {
            boolean granted = true;
            for (int res : grantResults) {
                if (res != PackageManager.PERMISSION_GRANTED) {
                    granted = false;
                    break;
                }
            }

            if (granted) {
                if (!isLocationEnabled()) {
                    askUserToEnableLocation();
                    pendingResult.success(false);
                } else if (!isWifiEnabled()) {
                    askUserToEnableWifi();
                    pendingResult.success(false);
                } else {
                    pendingResult.success(true);
                }
            } else {
                pendingResult.error("PERMISSION_DENIED", "Permissions denied", null);
            }

            pendingResult = null;
        }
    }

    private boolean isLocationEnabled() {
        LocationManager locationManager = (LocationManager) getSystemService(LOCATION_SERVICE);
        return locationManager != null &&
                (locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)
                        || locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER));
    }

    private void askUserToEnableLocation() {
        Intent intent = new Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS);
        startActivity(intent);
    }

    private boolean isWifiEnabled() {
        WifiManager wifiManager = (WifiManager) getApplicationContext().getSystemService(WIFI_SERVICE);
        return wifiManager != null && wifiManager.isWifiEnabled();
    }

    private void askUserToEnableWifi() {
        Intent intent = new Intent(Settings.ACTION_WIFI_SETTINGS);
        startActivity(intent);
    }

    private void getWifiScanResults(MethodChannel.Result result) {
        try {
            WifiManager wifiManager = (WifiManager) getApplicationContext().getSystemService(WIFI_SERVICE);
            if (wifiManager == null) {
                result.error("WIFI_ERROR", "WifiManager not available", null);
                return;
            }

            if (!wifiManager.isWifiEnabled()) {
                result.error("WIFI_DISABLED", "Wi-Fi is disabled", null);
                return;
            }

            wifiManager.startScan();
            List<ScanResult> scanResults = wifiManager.getScanResults();

            if (scanResults == null || scanResults.isEmpty()) {
                result.error("NO_NETWORKS", "No Wi-Fi networks found", null);
                return;
            }

            List<Map<String, Object>> networks = new ArrayList<>();
            for (ScanResult scanResult : scanResults) {
                Map<String, Object> network = new HashMap<>();
                network.put("ssid", scanResult.SSID);
                network.put("bssid", scanResult.BSSID);
                network.put("level", scanResult.level);
                network.put("frequency", scanResult.frequency);
                network.put("securityType", getSecurityType(scanResult)); // Add security type
                networks.add(network);
            }
            result.success(networks);
        } catch (Exception e) {
            result.error("SCAN_FAILED", e.getMessage(), null);
        }
    }

    private void connectToWifi(String ssid, String password, String securityType, String bssid,
            MethodChannel.Result result) {
        try {
            WifiManager wifiManager = (WifiManager) getApplicationContext().getSystemService(WIFI_SERVICE);
            if (wifiManager == null) {
                result.error("WIFI_ERROR", "WifiManager not available", null);
                return;
            }

            if (!wifiManager.isWifiEnabled()) {
                result.error("WIFI_DISABLED", "Wi-Fi is disabled", null);
                return;
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                connectUsingNetworkSuggestions(ssid, password, securityType, bssid, result);
            } else {
                connectUsingWifiConfiguration(ssid, password, securityType, bssid, result);
            }

        } catch (Exception e) {
            result.error("CONNECT_EXCEPTION", e.getMessage(), null);
        }
    }

    @androidx.annotation.RequiresApi(api = Build.VERSION_CODES.Q)
    private void connectUsingNetworkSuggestions(String ssid, String password, String securityType, String bssid,
            MethodChannel.Result result) {
        try {
            WifiManager wifiManager = (WifiManager) getApplicationContext().getSystemService(WIFI_SERVICE);

            removeWifiSuggestions(result);

            WifiNetworkSuggestion.Builder suggestionBuilder = new WifiNetworkSuggestion.Builder()
                    .setSsid(ssid).setPriority(Integer.MAX_VALUE)
                    .setIsAppInteractionRequired(true);

            // Add BSSID if provided
            if (bssid != null && !bssid.isEmpty()) {
                try {
                    MacAddress macAddress = MacAddress.fromString(bssid);
                    suggestionBuilder.setBssid(macAddress);
                } catch (IllegalArgumentException e) {
                    result.error("INVALID_BSSID", "Invalid BSSID format: " + bssid, null);
                    return;
                }
            }
            System.out.println("One Step Before Suggestion Build");
            // Configure based on security type
            switch (securityType.toUpperCase()) {
                case "WPA2":
                case "WPA":
                case "WPA_WPA2":
                    suggestionBuilder.setWpa2Passphrase(password);
                    break;
                case "WPA3":
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        suggestionBuilder.setWpa3Passphrase(password);
                    } else {
                        suggestionBuilder.setWpa2Passphrase(password);
                    }
                    break;
                case "WEP":
                    result.error("UNSUPPORTED_SECURITY", "WEP is not supported on Android 10+", null);
                    return;
                case "OPEN":
                case "NONE":
                    // Open network, no password needed
                    break;
                default:
                    suggestionBuilder.setWpa2Passphrase(password);
                    break;
            }

            WifiNetworkSuggestion suggestion = suggestionBuilder.build();
            List<WifiNetworkSuggestion> suggestionsList = new ArrayList<>();
            suggestionsList.add(suggestion);

            int status = wifiManager.addNetworkSuggestions(suggestionsList);

            if (status == WifiManager.STATUS_NETWORK_SUGGESTIONS_SUCCESS) {
                System.out.println("Suggestion Added Successfully");
                result.success(true);
            } else {
                System.out.println("Failed to add suggestion");
                String errorMessage = getNetworkSuggestionErrorMessage(status);
                result.error("SUGGESTION_FAILED", errorMessage, null);
            }
        } catch (Exception e) {
            result.error("SUGGESTION_EXCEPTION", e.getMessage(), null);
        }
    }

    private void connectUsingWifiConfiguration(String ssid, String password, String securityType, String bssid,
            MethodChannel.Result result) {
        try {
            WifiManager wifiManager = (WifiManager) getApplicationContext().getSystemService(WIFI_SERVICE);

            WifiConfiguration config = new WifiConfiguration();
            config.SSID = "\"" + ssid + "\"";

            // Add BSSID if provided
            if (bssid != null && !bssid.isEmpty()) {
                config.BSSID = bssid;
            }

            // Configure based on security type
            switch (securityType.toUpperCase()) {
                case "WPA2":
                case "WPA":
                case "WPA_WPA2":
                case "WPA3":
                    config.preSharedKey = "\"" + password + "\"";
                    config.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.WPA_PSK);
                    config.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.TKIP);
                    config.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.CCMP);
                    config.allowedPairwiseCiphers.set(WifiConfiguration.PairwiseCipher.TKIP);
                    config.allowedPairwiseCiphers.set(WifiConfiguration.PairwiseCipher.CCMP);
                    config.allowedProtocols.set(WifiConfiguration.Protocol.RSN);
                    config.allowedProtocols.set(WifiConfiguration.Protocol.WPA);
                    break;
                case "WEP":
                    config.wepKeys[0] = "\"" + password + "\"";
                    config.wepTxKeyIndex = 0;
                    config.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.NONE);
                    config.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.WEP40);
                    config.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.WEP104);
                    break;
                case "OPEN":
                case "NONE":
                    config.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.NONE);
                    break;
                default:
                    // Default to WPA2
                    config.preSharedKey = "\"" + password + "\"";
                    config.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.WPA_PSK);
                    break;
            }

            int netId = wifiManager.addNetwork(config);
            if (netId == -1) {
                result.error("CONNECT_ERROR", "Failed to add network config", null);
                return;
            }

            boolean enabled = wifiManager.enableNetwork(netId, true);
            boolean connected = wifiManager.reconnect();

            if (enabled && connected) {
                result.success(true);
            } else {
                result.error("CONNECT_FAILED", "Could not connect to " + ssid, null);
            }
        } catch (Exception e) {
            result.error("CONNECT_EXCEPTION", e.getMessage(), null);
        }
    }

    // Helper method to determine security type from scan result
    private String getSecurityType(ScanResult scanResult) {
        String capabilities = scanResult.capabilities.toLowerCase();
        if (capabilities.contains("wep")) {
            return "WEP";
        } else if (capabilities.contains("wpa3")) {
            return "WPA3";
        } else if (capabilities.contains("wpa2")) {
            return "WPA2";
        } else if (capabilities.contains("wpa")) {
            return "WPA";
        } else {
            return "OPEN";
        }
    }

    // Helper method to get error message for network suggestion status
    private String getNetworkSuggestionErrorMessage(int status) {
        switch (status) {
            case WifiManager.STATUS_NETWORK_SUGGESTIONS_ERROR_ADD_DUPLICATE:
                return "Network suggestion already exists";
            case WifiManager.STATUS_NETWORK_SUGGESTIONS_ERROR_ADD_EXCEEDS_MAX_PER_APP:
                return "Too many network suggestions";
            case WifiManager.STATUS_NETWORK_SUGGESTIONS_ERROR_REMOVE_INVALID:
                return "Invalid network suggestion to remove";
            case WifiManager.STATUS_NETWORK_SUGGESTIONS_ERROR_APP_DISALLOWED:
                return "App not allowed to add network suggestions";
            case WifiManager.STATUS_NETWORK_SUGGESTIONS_ERROR_INTERNAL:
                return "Internal error occurred";
            default:
                return "Unknown error: " + status;
        }
    }

    private void removeWifiSuggestions(MethodChannel.Result result) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                WifiManager wifiManager = (WifiManager) getApplicationContext().getSystemService(WIFI_SERVICE);

                if (wifiManager != null) {
                    List<WifiNetworkSuggestion> suggestionsList = wifiManager.getNetworkSuggestions();
                    System.out.println("Removing existing suggestions: " + suggestionsList.size());
                    System.out.println("Suggestions: " + suggestionsList.toString());
                    int status = wifiManager.removeNetworkSuggestions(suggestionsList);
                    // result.success(status == WifiManager.STATUS_NETWORK_SUGGESTIONS_SUCCESS);
                } else {
                    result.error("WIFI_ERROR", "WifiManager not available", null);
                }
            } else {
                // result.success(true); // No suggestions to remove on older versions
            }
        } catch (Exception e) {
            result.error("REMOVE_SUGGESTIONS_ERROR", e.getMessage(), null);
        }
    }
}