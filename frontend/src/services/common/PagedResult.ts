export type PagedResult<T=unknown> = {
    amount: number;
    page: number;
    pageSize: number;
    elements: T[];
}

export type PagedRequest = {
    id?: string;
    page: number;
    pageSize: number;
}