import {useEffect, useState} from "react";
interface Team {
    id: string;
    name: string;
}

export const TeamSelect = () => {
    const [teams, setTeams] = useState([] as Team[]);

    useEffect(() => {
        fetch('https://localhost:8080/api/teams')
            .then(response => response.json())
            .then(data => {
                console.log(data);
                setTeams(data);
            }
        );
    }, []);

    return (
        <select>
            {teams.map(team => (
                <option key={team.id} value={team.id}>{team.name}</option>
            ))}
        </select>
    );
}