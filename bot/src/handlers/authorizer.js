const generatePolicy = (principalId, Effect, Resource) => ({
  principalId,
  policyDocument: {
    Version: '2012-10-17',
    Statement: [
      {
        Action: 'execute-api:Invoke',
        Effect,
        Resource
      }
    ]
  }
});

const handler = ({ authorizationToken, methodArn }, context, callback) => callback(null, generatePolicy('user',
  authorizationToken === process.env.token ? 'Allow' : 'Deny', methodArn));

exports.handler = handler;
