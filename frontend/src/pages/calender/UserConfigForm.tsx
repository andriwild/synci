// import {
//   Button,
//   Card,
//   Flex,
//   Form,
//   Input,
//   Select
// } from "antd";
// import { useNavigate, useParams } from "react-router-dom";
// import { decodeAbbreviation } from "../../model/ski.ts";
// import { useEffect, useState } from "react";
// import { SyncConfig } from "../../model/SyncConfig.ts";
// import { useForm } from "antd/es/form/Form";
// import { Team } from "../../model/Team.ts";
// import { Api } from "../../services/data.tsx";
// import { FC } from "react";
// import {Sport} from "../../services/sport/entities/event.ts";
//
//
// export const UserConfigForm: FC = () => {
//     const navigate = useNavigate();
//     const [form] = useForm();
//     const { id: id } = useParams();
//     const createmode = id === 'new';
//
//     const [teams, setTeams] = useState([] as Team[]);
//     const [sports, setSports] = useState([] as Sport[]);
//
//     useEffect(() => {
//         Api.getTeams().then(setTeams);
//         Api.getSports().then(setSports);
//
//         // edit existing config - add teams to form
//         if (!createmode) {
//             Api.getSycnConfig(id ? id : 'new')
//                 .then(it => {
//                     form.setFieldsValue({
//                         teams: it.teams
//                             .sort((a: Team, b: Team) => a.name.localeCompare(b.name))
//                             .map((team:Team) => team.id),
//                         name: it.name,
//                         sports: it.sports
//                             .sort((a: Sport, b: Sport) => a.name.localeCompare(b.name))
//                             .map((sport:Sport) => sport.id)
//                     });
//                 })
//         }
//     }, []);
//
//     const handleSubmit = (values: { name: string, teams: number[], sports: string[] }) => {
//         let selectedTeams = [] as Team[];
//         let selectedSports = [] as Sport[];
//
//         if (values.teams !== undefined) {
//             selectedTeams = teams.filter(team => values.teams.includes(team.id));
//         }
//         if (values.sports !== undefined) {
//             selectedSports = sports.filter(sport => values.sports.includes(sport.id))
//         }
//
//         const syncConfig: SyncConfig = {
//             id: id && id !== 'new' ? id : null,
//             name: values.name,
//             teams: selectedTeams,
//             sports: selectedSports
//         }
//
//         const method = createmode ? 'POST' : 'PUT';
//         Api.createSyncConfig(id ? id : 'new', syncConfig,  method)
//             .then(handleBack)
//     };
//
//     const handleBack = () => navigate('/config');
//
//     return (
//         <Flex vertical style={{ height: '100%', width: '100%', padding: 24 }}>
//             <Card style={{ width: 600, textAlign: 'left' }}>
//
//                 <p>Füge eine Konfiguration hinzu. Wähle dabei aus, für welches Team, welchen Sportler, welchen Ort oder
//                 welche Sportart du dich interessierst</p>
//
//                 <Form
//                     autoComplete="off"
//                     form={ form }
//                     onFinish={ handleSubmit }
//                     layout={ 'vertical' }
//                     style={{ marginTop: 36 }}
//                 >
//
//                     <Form.Item name={ 'name' } label={ 'Config Name' }>
//                         <Input placeholder="Config Name" autoComplete="off"/>
//                     </Form.Item>
//
//                     <Form.Item name={ 'teams' } label={ 'Teams' }>
//                         <Select
//                             mode="multiple"
//                             placeholder="Teams auswählen"
//                             options={teams.map(team => ({ value: team.id, label: team.name }))}
//                             style={{ width: '100%' }}
//                         />
//                     </Form.Item>
//
//
//                     <Form.Item name={ 'sports' } label={ 'Sports' }>
//                         <Select
//                             mode="multiple"
//                             placeholder="Sportarten auswählen"
//                             options={sports.map(sport => ({ value: sport.id, label: decodeAbbreviation(sport.name) }))}
//                             style={{ width: '100%' }}
//                         />
//                     </Form.Item>
//
//                     <Flex gap={ 'middle' } justify={ 'end' } style={{ marginTop: 48, marginBottom: 12 }}>
//                         <Button onClick={ handleBack }>Zurück</Button>
//                         <Button htmlType={ 'submit' } type={ 'primary' }>Submit</Button>
//                     </Flex>
//
//                 </Form>
//             </Card>
//        </Flex>
//     );
// };
