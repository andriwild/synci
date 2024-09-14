import { useState } from 'react';

export const UserConfigForm = () => {
    const [formData, setFormData] = useState({
        team: '',
        person: '',
        location: '',
        type: ''
    });

    const teams = [
        { id: 'teamA', name: 'Team A' },
        { id: 'teamB', name: 'Team B' },
        { id: 'teamC', name: 'Team C' },
    ];

    const persons = [
        { id: 'person1', name: 'Max Mustermann' },
        { id: 'person2', name: 'Anna Beispiel' },
        { id: 'person3', name: 'Peter Muster' },
    ];

    const locations = [
        { id: 'zurich', name: 'Zürich' },
        { id: 'bern', name: 'Bern' },
        { id: 'geneva', name: 'Genf' },
    ];

    const types = [
        { id: 'football', name: 'Fußball' },
        { id: 'basketball', name: 'Basketball' },
        { id: 'tennis', name: 'Tennis' },
    ];

    const handleChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
        const { name, value } = e.target;
        setFormData({
            ...formData,
            [name]: value,
        });
    };

    const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
        e.preventDefault();
        console.log('Form submitted:', formData);
    };

    const handleBack = () => {
        console.log('Zurück-Button geklickt');
        // Zurück-routen
    };

    return (
        <form onSubmit={handleSubmit} style={{ width: 800, height: 500, margin: '0 auto', padding: '20px', backgroundColor: '#f9f9f9', borderRadius: '8px', boxShadow: '0 4px 8px rgba(0,0,0,0.1)' }}>
            <h2 style={{ marginBottom: '20px', textAlign: 'center' }}>Benutzerkonfigurationen</h2>
            <p>Füge eine Konfiguration hinzu. Wähle dabei aus, für welches Team, welchen Sportler, welchen Ort oder welche Sportart du dich interessierst</p>
            <div style={{ marginBottom: '15px', display: 'flex', alignItems: 'center' }}>
                <label htmlFor="team" style={{ width: '150px', fontWeight: 'bold' }}>Teams</label>
                <select name="team" id="team" value={formData.team} onChange={handleChange} style={{ flex: 1, padding: '8px', borderRadius: '4px', border: '1px solid #ddd' }}>
                    <option value="">Wähle ein Team</option>
                    {teams.map((team) => (
                        <option key={team.id} value={team.id}>
                            {team.name}
                        </option>
                    ))}
                </select>
            </div>
            <div style={{ marginBottom: '15px', display: 'flex', alignItems: 'center' }}>
                <label htmlFor="person" style={{ width: '150px', fontWeight: 'bold' }}>Personen</label>
                <select name="person" id="person" value={formData.person} onChange={handleChange} style={{ flex: 1, padding: '8px', borderRadius: '4px', border: '1px solid #ddd' }}>
                    <option value="">Wähle eine Person</option>
                    {persons.map((person) => (
                        <option key={person.id} value={person.id}>
                            {person.name}
                        </option>
                    ))}
                </select>
            </div>
            <div style={{ marginBottom: '15px', display: 'flex', alignItems: 'center' }}>
                <label htmlFor="location" style={{ width: '150px', fontWeight: 'bold' }}>Location (Schweiz)</label>
                <select name="location" id="location" value={formData.location} onChange={handleChange} style={{ flex: 1, padding: '8px', borderRadius: '4px', border: '1px solid #ddd' }}>
                    <option value="">Wähle eine Ortschaft</option>
                    {locations.map((location) => (
                        <option key={location.id} value={location.id}>
                            {location.name}
                        </option>
                    ))}
                </select>
            </div>
            <div style={{ marginBottom: '15px', display: 'flex', alignItems: 'center' }}>
                <label htmlFor="type" style={{ width: '150px', fontWeight: 'bold' }}>Type (Sportart)</label>
                <select name="type" id="type" value={formData.type} onChange={handleChange} style={{ flex: 1, padding: '8px', borderRadius: '4px', border: '1px solid #ddd' }}>
                    <option value="">Wähle eine Sportart</option>
                    {types.map((type) => (
                        <option key={type.id} value={type.id}>
                            {type.name}
                        </option>
                    ))}
                </select>
            </div>
            <div style={{ marginTop: '20px', display: 'flex', justifyContent: 'flex-end' }}>
                <button type="button" onClick={handleBack} style={{ backgroundColor: '#f5f5f5', border: '1px solid #ddd', borderRadius: '4px', padding: '10px 15px', cursor: 'pointer', marginRight: '10px' }}>
                    Zurück
                </button>
                <button type="submit" style={{ backgroundColor: '#2e69ff', border: 'none', borderRadius: '4px', color: 'white', padding: '10px 15px', cursor: 'pointer' }}>
                    Submit
                </button>
            </div>
        </form>
    );
};
