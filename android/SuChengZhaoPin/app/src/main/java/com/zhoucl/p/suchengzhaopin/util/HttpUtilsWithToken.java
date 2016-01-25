package com.zhoucl.p.suchengzhaopin.util;

import com.lidroid.xutils.HttpUtils;
import com.lidroid.xutils.http.HttpHandler;
import com.lidroid.xutils.http.RequestParams;
import com.lidroid.xutils.http.callback.RequestCallBack;
import com.lidroid.xutils.http.client.HttpRequest;
import com.lidroid.xutils.util.LogUtils;
import com.zhoucl.p.suchengzhaopin.ui.BaseActivity;

/**
 * Created by zhoucl on 2015/7/9.
 */
public class HttpUtilsWithToken extends HttpUtils {

    private boolean formatFlag = false;

    public <T> HttpHandler<T> send(HttpRequest.HttpMethod method, String url, RequestCallBack<T> callBack) {
        formatFlag = true;
        return this.send(method, urlFormat(url), (RequestParams) null, callBack);
    }

    @Override
    public <T> HttpHandler<T> send(HttpRequest.HttpMethod method, String url, RequestParams params, RequestCallBack<T> callBack) {
        if (!formatFlag) {
            return super.send(method, urlFormat(url), params, callBack);
        } else {
            formatFlag = false;
            return super.send(method, url, params, callBack);
        }
    }

    /**
     * get方式，编织URL
     *
     * @param url
     * @return
     */
    public String urlFormat(String url) {
        StringBuilder sb = new StringBuilder(url);
        if (url.contains("?")) {
            sb.append("&");
        } else {
            sb.append("?");
        }
        sb.append("token=");
        sb.append(BaseActivity.TOKEN);
        LogUtils.d("url : " + sb.toString());
        return sb.toString();
    }
}
