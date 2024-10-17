const abbreviationKey: { [key: string]: string } = {
    "WC": "World Cup",
    "EC": "Europa Cup",
    "FIS": "FIS",
    "M": "Men",
    "W": "Women",
    "DH": "Downhill",
    "SL": "Slalom",
    "GS": "Giant Slalom",
    "SG": "Super-G",
    "AC": "Alpine Combined",
    "TC": "Team Competition"
};

export const decodeAbbreviation = (abbreviation: string): string => {
    const parts = abbreviation.split('_');
    const decodedParts = parts.map(part => abbreviationKey[part] || part);
    return decodedParts.join(' ');
}
