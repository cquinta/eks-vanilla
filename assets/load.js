import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '30s', target: 10 }, 
    { duration: '30s', target: 20 }, 
    { duration: '30s', target: 30 }  
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% das requisições devem ser < 500ms
    http_req_failed: ['rate<0.01'],   // Erros abaixo de 1%
  },
};

const BASE_URL = 'http://cr.cquinta.com'

export default function () {
  let endpoints = [
    '/healthcheck'    
  ];

  for (let endpoint of endpoints) {
    let res = http.get(`${BASE_URL}${endpoint}`);

    check(res, {
      'status é 200': (r) => r.status === 200,
      'tempo de resposta < 500ms': (r) => r.timings.duration < 500,
    });
  }
}