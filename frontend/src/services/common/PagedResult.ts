


export type PagedResult<T=unknown> = {
    currentPage: number;
    totalPages: number;
    results: T[];
    pageSize?: number;
    totalElements?: number;
}

export type NativePagedResult<T=unknown> = {
    number: number;
    totalPages: number;
    content: T[];
    size?: number;
    totalElements?: number;
}

export type PagedRequest = {
    page: number;
    pageSize?: number;
}
