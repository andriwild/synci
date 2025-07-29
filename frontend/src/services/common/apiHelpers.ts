
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

export const axiosBaseQuery = ({ baseUrl }: { baseUrl: string }) => {
    const axiosInstance = axios.create({
        baseURL: VITE_BACKEND_URL + "api" + baseUrl
    });

    axiosInstance.interceptors.request.use(
        (config) => {
            try {
                const user = localStorage.getItem('user') ? JSON.parse(localStorage.getItem('user') || '{}') : null;
                if (!user) {
                    console.warn('Kein User im LocalStorage gefunden, Auth Header wird nicht gesetzt.');
                    return config;
                }
                console.log("State:", user);

                if (user?.token) {
                    config.headers.Authorization = `Bearer ${user.token}`;
                }
            } catch (error) {
                console.warn('Fehler beim Hinzufügen des Auth Headers:', error);
            }
            return config;
        },
        (error) => {
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