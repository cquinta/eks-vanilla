import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '30s', target: 10 }, // Aumenta para 10 usuários em 10s
    { duration: '30s', target: 20 }, // Mantém 10 usuários por 20s
    { duration: '30s', target: 30 }   // Reduz gradualmente para 0 usuários
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% das requisições devem ser < 500ms
    http_req_failed: ['rate<0.01'],   // Erros abaixo de 1%
  },
};

const BASE_URL = 'http://chip-green.chip.svc.cluster.local:8080'

export default function () {
  let endpoints = [
    '/version',
    '/system',
    '/system/environment',
  ];

  for (let endpoint of endpoints) {
    let res = http.get(`${BASE_URL}${endpoint}`);

    check(res, {
      'status é 200': (r) => r.status === 200,
      'tempo de resposta < 500ms': (r) => r.timings.duration < 500,
    });
  }
}