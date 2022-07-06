package in.theweekenddeveloper.barometer;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * BarometerPlugin
 */
public class BarometerPlugin implements FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler, SensorEventListener {
    private Context applicationContext;

    private SensorManager mSensorManager;
    private Sensor mBarometer;

    private float mLatestReading = 0;

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel methodChannel;
    private EventChannel eventChannel;

    private EventChannel.EventSink mEventSink;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        applicationContext = flutterPluginBinding.getApplicationContext();
        methodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "barometer");
        methodChannel.setMethodCallHandler(this);

        eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "pressureStream");
        eventChannel.setStreamHandler(this);
    }

    float getBarometer() {
        return mLatestReading;
    }

    boolean initializeBarometer() {
        mSensorManager = (SensorManager) applicationContext.getSystemService(Context.SENSOR_SERVICE);
        mBarometer = mSensorManager.getDefaultSensor(Sensor.TYPE_PRESSURE);
        mSensorManager.registerListener(this, mBarometer, SensorManager.SENSOR_DELAY_NORMAL);
        return true;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
            return;
        }

        if (call.method.equals("getReading")) {
            double reading = getBarometer();
            result.success(reading);
            return;
        }

        if (call.method.equals("initializeBarometer")) {
            result.success(initializeBarometer());
            return;
        }

        result.notImplemented();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        applicationContext = null;
        methodChannel.setMethodCallHandler(null);
        methodChannel = null;
        eventChannel.setStreamHandler(null);
        eventChannel = null;
    }

    @Override
    public void onSensorChanged(SensorEvent sensorEvent) {
        mLatestReading = sensorEvent.values[0];

        if (mEventSink != null) {
            mEventSink.success(mLatestReading);
        }
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int i) {
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        mEventSink = events;
    }

    @Override
    public void onCancel(Object arguments) {

    }
}
