import { SyncConfig } from '../model/SyncConfig';
const env = import.meta.env

const BACKEND_URL = env.VITE_BACKEND_URL ? env.VITE_BACKEND_URL + '/api': 'http://localhost:8080/api'


async function apiFetch(endpoint: string, options?: RequestInit) {
    return await fetch(`${BACKEND_URL}${endpoint}`, options);
}

export const Api = {
    getSyncConfigUrl: (id: string) => {
        return `${BACKEND_URL}/calendar/subscribe/${id}`
    },
    getTeams: async () => {
        return apiFetch('/team/list')
        .then(response => response.json())
    },
    getSports: async () => {
        return apiFetch('/swissski/list')
        .then(response => response.json())
    },

    deleteSyncConfig: async (id: string) => {
        return apiFetch(`/syncconfig/${id}`, {
            method: 'DELETE',
        })
            .then(response => response.json())
            .catch(error => console.error('Error: deleteSyncConfig', error));
    },
    getAllSycnConfigs: async () => {
        return apiFetch('/syncconfig/list')
            .then(response => response.json())
            .catch(error => console.error('Error: getAllConfigs', error));
    },

    getSycnConfig: async (id: string) => {
        return apiFetch('/syncconfig/' + id)
        .then(response => response.json())
    },

    createSyncConfig: async (id: string, body: SyncConfig, method: string = 'POST') => {
        return apiFetch(`/syncconfig/${id}`,{
            method: method,
            body: JSON.stringify(body),
            headers: {'Content-Type': 'application/json'}
        })
            .catch(error => console.error('Error: createSyncConfig', error));
    },
};
