import { SyncConfig } from '../model/SyncConfig';

const LOCAL_BACKEND_URL = 'http://localhost:8080/api' 
const BACKEND_URL = 'https://synci.awild.ch/api'

const BASE_URL = import.meta.env.DEV ? LOCAL_BACKEND_URL: BACKEND_URL


async function apiFetch(endpoint: string, options?: RequestInit) {
    return await fetch(`${BASE_URL}${endpoint}`, options);
}

export const Api = {
    getSyncConfigUrl: (id: string) => {
        return `${BASE_URL}/calendar?syncConfigId=${id}`
    },
    getTeams: async () => {
        return apiFetch('/team/list')
        .then(response => response.json())
    },

    deleteSyncConfig: async (id: string) => {
        return apiFetch(`/syncconfig/${id}`, {
            method: 'DELETE',
            mode: 'cors',
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
            mode: 'cors',
            body: JSON.stringify(body),
            headers: {'Content-Type': 'application/json'}
        })
            .catch(error => console.error('Error: createSyncConfig', error));
    },
};
