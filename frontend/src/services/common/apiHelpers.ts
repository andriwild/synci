
import axios from 'axios';
import {type BaseQueryFn, retry} from '@reduxjs/toolkit/query/react'
import type {AxiosError, AxiosRequestConfig} from 'axios'
import {VITE_BACKEND_URL} from '../../../env.ts';
import {SerializedError} from '@reduxjs/toolkit';

type AxiosBaseQueryFn = BaseQueryFn<
    {
        url: string
        method: AxiosRequestConfig['method']
        body?: AxiosRequestConfig['data']
        params?: AxiosRequestConfig['params']
        headers?: AxiosRequestConfig['headers']
        muteNotification?: boolean
    },
    unknown,
    HttpError
>;

interface Auth0Client {
    getTokenSilently: () => Promise<string>;
    loginWithRedirect: () => Promise<void>;
}

let auth0Client: Auth0Client | null = null;

export const setAuth0Client = (client: Auth0Client) => {
    auth0Client = client;
};

export const axiosBaseQuery = ({ baseUrl }: { baseUrl: string }) => {
    const axiosInstance = axios.create({
        baseURL: VITE_BACKEND_URL + "api" + baseUrl
    });

    axiosInstance.interceptors.request.use(
        async (config) => {
            if (auth0Client) {
                try {
                    const token = await auth0Client.getTokenSilently();
                    config.headers.Authorization = `Bearer ${token}`;
                } catch (error) {
                    console.warn('Token abruf fehlgeschlagen:', error);
                }
            }
            return config;
        },

        (error) => {
            return Promise.reject(error);
        }
    );

    axiosInstance.interceptors.response.use(
        (response) => response,
        async (error) => {
            const originalRequest = error.config;
            
            if (error.response?.status === 401 && !originalRequest._retry && auth0Client) {
                originalRequest._retry = true;
                
                try {
                    const newToken = await auth0Client.getTokenSilently();
                    originalRequest.headers.Authorization = `Bearer ${newToken}`;
                    return axiosInstance(originalRequest);
                } catch (refreshError) {
                    console.error('Token refresh fehlgeschlagen:', refreshError);
                    await auth0Client.loginWithRedirect();
                }
            }
            
            return Promise.reject(error);
        }
    );

    const fn: AxiosBaseQueryFn = async ({ url, method, body, params, headers }) => {
        try {
            const result = await axiosInstance({
                url,
                method,
                data: body,
                params,
                headers
            });

            return { data: result.data.body };
        } catch (axiosError) {
            const err = axiosError as AxiosError;
            return {
                error: {
                    status: err.response?.status,
                    data: err.response?.data || { message: err.message },
                } as HttpError,
            };
        }
    };

    return retry(fn, { maxRetries: 0 });
};

export interface HttpError {
    status: number;
    data: {
        message: string;
        errors?: Record<string, string>;
    };
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const isHttpError = (error: any): error is HttpError => {
    return error.status && error.data;
}

export const stringifyApiError = (error: HttpError|SerializedError) => {
    if (!error) {
        return "Unbekannter Fehler";
    }
    if (isHttpError(error)) {
        return "Ein Fehler ist aufgetreten: " + error.data.message;
    }
    return "Ein Fehler ist aufgetreten: " + JSON.stringify(error);
}