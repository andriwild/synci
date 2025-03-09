export const convertToSwissDate = (date: string): string => {
    const dateObj = new Date(date);
    return dateObj.toLocaleDateString('de-CH');
}