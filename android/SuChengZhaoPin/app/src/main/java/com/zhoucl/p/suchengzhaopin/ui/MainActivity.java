package com.zhoucl.p.suchengzhaopin.ui;

import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.support.v4.app.FragmentTabHost;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TabHost;
import android.widget.TextView;

import com.zhoucl.p.suchengzhaopin.R;
import com.zhoucl.p.suchengzhaopin.util.ExitApplication;
import com.zhoucl.p.suchengzhaopin.util.HttpUtilsWithToken;
import com.zhoucl.p.suchengzhaopin.util.MainTabEnum;


public class MainActivity extends BaseActivity {

    private FragmentTabHost mTabHost;

    private int currentTab = 0;
    public static HttpUtilsWithToken httpUtilsWithToken;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.layout_main);

        currentTab = 0;
        httpUtilsWithToken = new HttpUtilsWithToken();
        initView();
    }

    private void initView() {
        mTabHost = (FragmentTabHost) findViewById(android.R.id.tabhost);
        mTabHost.setup(this, getSupportFragmentManager(), R.id.realtabcontent);

        final MainTabEnum[] tabs = MainTabEnum.values();
        final int size = tabs.length;
        for (int i = 0; i < size; i++) {
            MainTabEnum mainTab = tabs[i];
            TabHost.TabSpec tab = mTabHost.newTabSpec(getResources().getString(mainTab.getMenuName()));
            View indicator = LayoutInflater.from(this).inflate(R.layout.tab_indicator, null);
            TextView title = (TextView) indicator.findViewById(R.id.tab_title);
            Drawable drawable = this.getResources().getDrawable(mainTab.getMenuIcon());
            title.setCompoundDrawablesWithIntrinsicBounds(null, drawable, null, null);
            title.setText(mainTab.getMenuName());
            tab.setIndicator(indicator);
            tab.setContent(new TabHost.TabContentFactory() {

                @Override
                public View createTabContent(String tag) {
                    return new View(MainActivity.this);
                }
            });
            mTabHost.addTab(tab, mainTab.getClz(), null);
        }

        mTabHost.setOnTabChangedListener(new TabHost.OnTabChangeListener() {
            @Override
            public void onTabChanged(String tabId) {
                //
                currentTab = mTabHost.getCurrentTab();
            }
        });
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0) {
            if (currentTab == 0) {
                if (SearchFragment.onBackPress()) {
                    return false;
                }
            }
            ExitApplication.getInstance().exit();
        }
        return super.onKeyDown(keyCode, event);
    }
}
