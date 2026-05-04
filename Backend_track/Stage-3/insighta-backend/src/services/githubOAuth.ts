import axios from 'axios';
import { config } from '../config';

export async function exchangeCodeForToken(code: string, codeVerifier?: string) {
  const params: any = {
    client_id: config.githubClientId,
    client_secret: config.githubClientSecret,
    code,
  };
  if (codeVerifier) {
    params.code_verifier = codeVerifier;
  }
  const response = await axios.post('https://github.com/login/oauth/access_token', params, {
    headers: { Accept: 'application/json' },
  });
  return response.data.access_token;
}

export async function getGitHubUser(accessToken: string) {
  const { data } = await axios.get('https://api.github.com/user', {
    headers: { Authorization: `token ${accessToken}` },
  });
  return {
    github_id: data.id.toString(),
    username: data.login,
    email: data.email,
    avatar_url: data.avatar_url,
  };
}