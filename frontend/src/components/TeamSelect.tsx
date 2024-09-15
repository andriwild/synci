import {FC, useEffect, useState} from "react";
import {Select} from "antd";
interface Team {
    id: string;
    name: string;
}
interface TeamSelectProps {
    value?: Team[]; // Wert, der von der Form übergeben wird
    onChange?: (value: Team[]) => void; // Handler, um den Wert zu ändern
}

export const TeamSelect: FC<TeamSelectProps> = ({ value, onChange }) => {

    const [teamsQuery, setTeamsQuery] = useState([] as Team[]);

    useEffect(() => {
        fetch('http://localhost:8080/api/team/list')
            .then(response => response.json())
            .then(data => {
                console.log(data);
                setTeamsQuery(data);
            }
        );
    }, []);


    return (
        <Select
            mode="multiple"
            placeholder="Teams auswählen"
            value={value} // kontrollierter Wert vom Formular
            onChange={onChange} // Handler, um den neuen Wert an das Formular zu übergeben
            style={{ width: '100%' }}
        >
            {teamsQuery.map(team => (
                <Select.Option key={team.id} value={team.id}>
                    {team.name}
                </Select.Option>
            ))}
        </Select>
    );
}
