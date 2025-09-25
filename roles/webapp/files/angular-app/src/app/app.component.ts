import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { interval } from 'rxjs';

interface ServerStatus {
  message: string;
  server: string;
  uptime: string;
  database: string;
  timestamp: string;
}

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html'
})
export class AppComponent implements OnInit {
  servers: ServerStatus[] = [];
  loading = false;
  lastUpdate = new Date();

  constructor(private http: HttpClient) {}

  ngOnInit() {
    this.loadServerStatus();
    // Auto-refresh every 5 seconds
    interval(5000).subscribe(() => this.loadServerStatus());
  }

  loadServerStatus() {
    this.loading = true;
    const requests = Array.from({length: 10}, (_, i) => 
      this.http.get<ServerStatus>('/api/')
    );

    Promise.all(requests.map(req => req.toPromise()))
      .then(responses => {
        this.servers = responses.filter(Boolean) as ServerStatus[];
        this.lastUpdate = new Date();
        this.loading = false;
      })
      .catch(error => {
        console.error('Error loading server status:', error);
        this.loading = false;
      });
  }

  getUniqueServers() {
    const unique = new Map();
    this.servers.forEach(server => {
      if (!unique.has(server.server) || 
          new Date(server.timestamp) > new Date(unique.get(server.server).timestamp)) {
        unique.set(server.server, server);
      }
    });
    return Array.from(unique.values());
  }

  refresh() {
    this.loadServerStatus();
  }
}
