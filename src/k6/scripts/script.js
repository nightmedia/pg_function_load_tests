import { check } from "k6";
import http from "k6/http";
import { textSummary } from 'https://jslib.k6.io/k6-summary/0.0.2/index.js';
// import { open } from 'k6/experimental/fs';

const stamp = __ENV.STAMP;
const tag = __ENV.TAG;
const records = Number(__ENV.RECORDS || "10")
const duration = __ENV.DURATION || "60s";
const target = Number(__ENV.TARGET || "100");

const url = 'http://' + tag + ':' + __ENV.PORT + (__ENV.REQ_PATH ? __ENV.REQ_PATH : '/api/test-data') + "?" + 
    Object.entries({
        _records: records,
        _text_param: 'ABCDEFGHIJKLMNOPRSTUVWXYZ',
        _int_param: 1234567890,
        _ts_param: new Date('2014-12-31').toISOString(),
        _bool_param: true
    })
    .map(([key, value]) => `${key}=${encodeURIComponent(value)}`)
    .join('&');

// define configuration
export const options = {
    // define thresholds
    thresholds: {
        http_req_failed: [{ threshold: "rate<0.01", abortOnFail: true }], // availability threshold for error rate
        http_req_duration: ["p(99)<1000"], // Latency threshold for percentile
    },
    // define scenarios
    scenarios: {
        breaking: {
            executor: "ramping-vus",
            stages: [
                { duration: duration, target: target },
            ],
        },
    },
};

export default function () {
    const res = http.get(url);
    check(res, {
        [`${tag} status is 200`]: (r) => r.status === 200,
        [`${tag} response is JSON`]: (r) => r.headers['Content-Type'] && r.headers['Content-Type'].includes('application/json'),
        [`${tag} response has data`]: (r) => r.body && JSON.parse(r.body).length > 0,
    });
}

export function handleSummary(data) {
    return {
        [`/results/${stamp}/${tag}_summary.txt`]: textSummary(data, { indent: ' ', enableColors: false }),
        [`/results/${stamp}/${tag}.csv`]: `${data.metrics.http_reqs.values.count},${data.metrics.http_reqs.values.rate},${data.metrics.http_req_failed.values.rate}`,
        //[`/results/${stamp}/${tag}_summary.json`]: JSON.stringify(data, null, 2),
    }
}
