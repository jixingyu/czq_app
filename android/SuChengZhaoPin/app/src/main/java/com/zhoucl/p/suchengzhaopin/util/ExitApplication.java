/**
 * @author zhoucl
 * manage all activity
 */

package com.zhoucl.p.suchengzhaopin.util;

import android.app.Activity;
import android.app.Application;
import android.os.Handler;
import android.os.Message;

import java.util.LinkedList;
import java.util.List;

public class ExitApplication extends Application {
    private List<Activity> activityList = new LinkedList<Activity>();
    private static ExitApplication instance;

    private ExitApplication() {
    }

    public static ExitApplication getInstance() {
        if (null == instance) {
            instance = new ExitApplication();
        }
        return instance;
    }

    public void addActivity(Activity activity) {
        activityList.add(activity);
    }

    public void exit() {
        for (Activity activity : activityList) {
            activity.finish();
        }
        Handler handler = new Handler(){
            @Override
            public void handleMessage(Message msg) {
                System.exit(0);
            }
        };
        handler.sendEmptyMessageDelayed(0, 1000);
    }
}
