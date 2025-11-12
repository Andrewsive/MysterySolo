import { DownloadItem, DownloadStatus } from './types';
import { getScript } from './store';

const downloadStore: DownloadItem[] = [
  {
    scriptId: 'demo',
    status: 'completed',
    progress: 100,
    speedKBps: 0,
    etaMinutes: 0,
    sizeMB: getScript('demo')?.sizeMB ?? 32,
    updatedAt: Date.now()
  },
  {
    scriptId: 'echo',
    status: 'notDownloaded',
    progress: 0,
    speedKBps: 0,
    etaMinutes: 0,
    sizeMB: getScript('echo')?.sizeMB ?? 28,
    updatedAt: Date.now()
  },
  {
    scriptId: 'atelier',
    status: 'paused',
    progress: 45,
    speedKBps: 180,
    etaMinutes: 12,
    sizeMB: getScript('atelier')?.sizeMB ?? 48,
    updatedAt: Date.now()
  }
];

function clone(item: DownloadItem): DownloadItem {
  return {
    scriptId: item.scriptId,
    status: item.status,
    progress: item.progress,
    speedKBps: item.speedKBps,
    etaMinutes: item.etaMinutes,
    sizeMB: item.sizeMB,
    updatedAt: item.updatedAt
  };
}

function findIndex(scriptId: string): number {
  return downloadStore.findIndex((item: DownloadItem) => item.scriptId === scriptId);
}

export function listDownloads(): DownloadItem[] {
  return downloadStore.map((item: DownloadItem) => clone(item));
}

export function getDownload(scriptId: string): DownloadItem | undefined {
  const idx = findIndex(scriptId);
  if (idx < 0) {
    return undefined;
  }
  return clone(downloadStore[idx]);
}

function updateItem(scriptId: string, updater: (item: DownloadItem) => void): void {
  const idx = findIndex(scriptId);
  if (idx < 0) {
    return;
  }
  const draft = downloadStore[idx];
  updater(draft);
  draft.updatedAt = Date.now();
}

export function startOrResumeDownload(scriptId: string): void {
  const idx = findIndex(scriptId);
  if (idx < 0) {
    const script = getScript(scriptId);
    downloadStore.push({
      scriptId,
      status: 'downloading',
      progress: 5,
      speedKBps: 240,
      etaMinutes: 10,
      sizeMB: script?.sizeMB ?? 20,
      updatedAt: Date.now()
    });
    return;
  }
  updateItem(scriptId, (draft: DownloadItem) => {
    const prevStatus = draft.status;
    draft.status = 'downloading';
    draft.progress = draft.progress >= 95 ? 100 : draft.progress + 5;
    if (prevStatus !== 'downloading') {
      draft.speedKBps = 260;
    }
    draft.etaMinutes = draft.etaMinutes > 1 ? draft.etaMinutes - 1 : 1;
  });
}

export function pauseDownload(scriptId: string): void {
  updateItem(scriptId, (draft: DownloadItem) => {
    draft.status = 'paused';
    draft.speedKBps = 0;
  });
}

export function completeDownload(scriptId: string): void {
  updateItem(scriptId, (draft: DownloadItem) => {
    draft.status = 'completed';
    draft.progress = 100;
    draft.speedKBps = 0;
    draft.etaMinutes = 0;
  });
}

export function deleteDownload(scriptId: string): void {
  const idx = findIndex(scriptId);
  if (idx >= 0) {
    downloadStore.splice(idx, 1);
  }
}

export function isDownloaded(scriptId: string): boolean {
  return getDownloadStatus(scriptId) === 'completed';
}

export function getDownloadStatus(scriptId: string): DownloadStatus {
  const item = getDownload(scriptId);
  return item ? item.status : 'notDownloaded';
}

