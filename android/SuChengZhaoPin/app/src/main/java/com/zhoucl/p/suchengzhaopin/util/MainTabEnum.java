package com.zhoucl.p.suchengzhaopin.util;

import com.zhoucl.p.suchengzhaopin.R;
import com.zhoucl.p.suchengzhaopin.ui.AboutFragment;
import com.zhoucl.p.suchengzhaopin.ui.SearchFragment;
import com.zhoucl.p.suchengzhaopin.ui.UserCenterFragment;

public enum MainTabEnum {
    SEARCH(0, R.string.tab_search, R.drawable.tab_icon_search, SearchFragment.class),

    ABOUT(1, R.string.tab_about, R.drawable.tab_icon_about, AboutFragment.class),

    USER_CENTER(2, R.string.tab_user_center, R.drawable.tab_icon_user_center, UserCenterFragment.class);

    private int menuIndex;
    private int menuName;
    private int menuIcon;
    private Class<?> clz;

    private MainTabEnum(int menuIndex, int menuName, int menuIcon, Class<?> clz) {
        this.menuIndex = menuIndex;
        this.menuName = menuName;
        this.menuIcon = menuIcon;
        this.clz = clz;
    }

    public int getMenuIndex() {
        return menuIndex;
    }

    public void setMenuIndex(int menuIndex) {
        this.menuIndex = menuIndex;
    }

    public int getMenuName() {
        return menuName;
    }

    public void setMenuName(int menuName) {
        this.menuName = menuName;
    }

    public int getMenuIcon() {
        return menuIcon;
    }

    public void setMenuIcon(int menuIcon) {
        this.menuIcon = menuIcon;
    }

    public Class<?> getClz() {
        return clz;
    }

    public void setClz(Class<?> clz) {
        this.clz = clz;
    }

}