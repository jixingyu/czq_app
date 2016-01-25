package com.zhoucl.p.suchengzhaopin.ui;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.text.Selection;
import android.text.Spannable;
import android.util.Base64;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;

import com.afollestad.materialdialogs.MaterialDialog;
import com.zhoucl.p.suchengzhaopin.R;
import com.zhoucl.p.suchengzhaopin.model.NativePlace;
import com.zhoucl.p.suchengzhaopin.util.ExitApplication;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.StreamCorruptedException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * Created by zhoucl on 2015/6/25.
 */
public class BaseActivity extends FragmentActivity {

    public static String IP = "http://czq.justxy.com";
    //
    public static String USER_CONFIG_PREFERENCE = "user_config_preference";
    public static String CONFIG_KEY_DEGREE = "degree";
    public static String CONFIG_KEY_DISTRICT = "district";
    public static String CONFIG_KEY_POLITICAL_STATUS = "political_status";
    public static String KEY_CURRENT_DISTRICT = "current_district";
    public static String KEY_CURRENT_DISTRICT_POSITION = "current_district_position";
    //
    public static String USER_INFO_PREFERENCE = "user_info_preference";
    public static String KEY_TOKEN = "token";
    public static String KEY_EMAIL = "email";
    public static String KEY_REAL_NAME = "real_name";
    public static String KEY_MOBILE = "mobile";
    public static String KEY_IS_ACTIVE = "is_active";

    public static String TOKEN = "";
    public static int RESUME_LIMIT;

    public static SharedPreferences configPreferences;
    public static SharedPreferences userInfoPreferences;

    private MaterialDialog progressDialog;
    private MaterialDialog reLoginDialog;

    public static boolean isLoginSuccessful = false;

    public static NativePlace nativePlace;

    public InputMethodManager inputManager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        ExitApplication.getInstance().addActivity(this);
        configPreferences = getSharedPreferences(USER_CONFIG_PREFERENCE, Activity.MODE_PRIVATE);
        userInfoPreferences = getSharedPreferences(USER_INFO_PREFERENCE, Activity.MODE_PRIVATE);

        inputManager = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
    }

    /**
     * get方式，编织URL
     *
     * @param url
     * @param map
     * @return
     */
    public String urlFormat(String url, HashMap<String, Object> map) {
        StringBuilder sb = new StringBuilder(url);
        sb.append("?");
        Iterator iterator = map.entrySet().iterator();
        while (iterator.hasNext()) {
            Map.Entry entry = (Map.Entry) iterator.next();
            sb.append(entry.getKey());
            sb.append("=");
            sb.append(entry.getValue());
            sb.append("&");
        }
        String new_url = sb.toString();
        return new_url.substring(0, new_url.length() - 1);
    }

    public void showProgressDialog() {
        if (progressDialog == null) {
            progressDialog = new MaterialDialog.Builder(this)
                    .content(R.string.loading)
                    .progress(true, 0)
                    .cancelable(false)
                    .build();
        }
        if (!progressDialog.isShowing()) {
            progressDialog.show();
        }
    }

    public void cancelProgressDialog() {
        if (progressDialog == null) {
            return;
        }
        if (progressDialog.isShowing()) {
            progressDialog.dismiss();
        }
    }

    public static String list2String(List<String> list)
            throws IOException {
        // 实例化一个ByteArrayOutputStream对象，用来装载压缩后的字节文件。
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        // 然后将得到的字符数据装载到ObjectOutputStream
        ObjectOutputStream objectOutputStream = new ObjectOutputStream(byteArrayOutputStream);
        // writeObject 方法负责写入特定类的对象的状态，以便相应的 readObject 方法可以还原它
        objectOutputStream.writeObject(list);
        // 最后，用Base64.encode将字节文件转换成Base64编码保存在String中
        String string = new String(Base64.encode(byteArrayOutputStream.toByteArray(), Base64.DEFAULT));
        // 关闭objectOutputStream
        objectOutputStream.close();
        return string;
    }

    @SuppressWarnings("unchecked")
    public static List<String> string2List(String string)
            throws StreamCorruptedException, IOException,
            ClassNotFoundException {
        byte[] mobileBytes = Base64.decode(string.getBytes(), Base64.DEFAULT);
        ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(mobileBytes);
        ObjectInputStream objectInputStream = new ObjectInputStream(byteArrayInputStream);
        List<String> list = (List<String>) objectInputStream.readObject();
        objectInputStream.close();
        return list;
    }

    public HashMap<String, Object> parseSimpleJson(String jsonStr) {
        HashMap<String, Object> map = new HashMap<>();
        try {
            JSONObject jObj = new JSONObject(jsonStr);
            if (!jObj.isNull("code")) {
                map.put("code", jObj.getInt("code"));
            }
            if (!jObj.isNull("error")) {
                map.put("error", jObj.getString("error"));
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return map;
    }

    /**
     * 判断登录状态
     * @param code 40103：请先登录； 40104：登录已过期
     * @param context
     * @return
     */
    public boolean checkLoginState (int code, final Context context) {
        if (code == 40103) {
            Intent intent = new Intent(context, LoginActivity.class);
            startActivity(intent);
            return false;
        } else if (code == 40104) {
            if (reLoginDialog == null) {
                reLoginDialog = new MaterialDialog.Builder(this)
                        .title(R.string.login_overdue)
                        .content(R.string.login_overdue_content)
                        .cancelable(false)
                        .positiveText(android.R.string.ok)
                        .negativeText(android.R.string.cancel)
                        .callback(new MaterialDialog.ButtonCallback() {
                            @Override
                            public void onPositive(MaterialDialog dialog) {
                                super.onPositive(dialog);
                                Intent intent = new Intent(context, LoginActivity.class);
                                startActivity(intent);
                                TOKEN = "";
                                SharedPreferences.Editor editor = userInfoPreferences.edit();
                                editor.clear();
                                editor.commit();
                            }

                            @Override
                            public void onNegative(MaterialDialog dialog) {
                                super.onNegative(dialog);
                                TOKEN = "";
                                SharedPreferences.Editor editor = userInfoPreferences.edit();
                                editor.clear();
                                editor.commit();
                            }
                        })
                        .build();
            }
            reLoginDialog.show();
            return false;
        }
        return true;
    }

    public void showSoftInput (EditText editText) {
        inputManager.showSoftInput(editText, 0);
        CharSequence text = editText.getText();
        if (text instanceof Spannable) {
            Spannable spanText = (Spannable)text;
            Selection.setSelection(spanText, text.length());
            }
    }

}
