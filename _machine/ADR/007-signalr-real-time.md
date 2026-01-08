# ADR-007: SignalR for Real-Time Communication

**Status:** Accepted
**Date:** 2024-06-20
**Decision Makers:** Backend Team, Frontend Team

## Context

Brand2Boost's chat feature needs real-time bidirectional communication:
- AI responses stream word-by-word (like ChatGPT)
- Users see typing indicators
- Multiple users can collaborate on same brand (future)
- Push notifications for completed tasks

**Requirements:**
- Real-time, bidirectional (server can push to client)
- Works with existing ASP.NET Core + React stack
- Scalable (supports horizontal scaling)
- Fallback for restrictive firewalls
- TypeScript client support

## Decision

**Use SignalR** (ASP.NET Core's WebSocket library) for real-time communication.

**Architecture:**
- WebSocket connection from React frontend to ASP.NET backend
- Server pushes chat messages as they arrive from LLM
- Automatic reconnection on disconnect
- Falls back to Server-Sent Events (SSE) or long polling if WebSockets blocked

## Consequences

### Positive
✅ **Native ASP.NET Integration**
- Built into ASP.NET Core (no extra dependency)
- Works seamlessly with authentication
- Easy to set up

✅ **Streaming AI Responses**
- LLM tokens stream to client in real-time
- Feels like ChatGPT (word-by-word)
- Better UX than waiting for full response

✅ **Bidirectional**
- Server can push to client (not just request-response)
- Typing indicators
- Notifications
- Collaborative editing (future)

✅ **Automatic Reconnection**
- If connection drops, SignalR reconnects
- No manual retry logic needed
- Resilient to network issues

✅ **Transport Fallback**
- 1st choice: WebSockets (best performance)
- Fallback: Server-Sent Events (SSE)
- Last resort: Long polling
- Works even behind restrictive proxies

✅ **Scalability**
- Can use Azure SignalR Service for horizontal scaling
- Offload connection management to managed service
- Supports thousands of concurrent connections

### Negative
❌ **Stateful Connections**
- Each user maintains persistent connection
- Harder to scale than stateless REST
- Need sticky sessions or backplane (Redis/Azure SignalR)

❌ **Complexity**
- More complex than REST API
- Connection lifecycle management
- Error handling is trickier

❌ **Testing Challenges**
- Harder to test than HTTP endpoints
- Need to mock WebSocket connections
- Integration tests more complex

### Neutral
⚪ **Resource Usage**
- Persistent connections use more server resources
- But: Modern servers handle 10K+ connections easily
- Trade-off worth it for UX

## Alternatives Considered

### Option A: Server-Sent Events (SSE) Only
**How it works:**
- HTTP stream from server to client
- One-way (server → client)

**Pros:**
- Simpler than WebSockets
- Works over HTTP (no special protocol)
- Good browser support

**Cons:**
- **One-way only** (client can't send on same connection)
- Must use separate HTTP POST for client → server
- Less efficient than WebSockets

**Why rejected:** Need bidirectional. SignalR includes SSE as fallback anyway.

### Option B: Polling (HTTP Long Polling)
**How it works:**
- Client polls server every N seconds
- Server holds request open until data available

**Pros:**
- Works everywhere (plain HTTP)
- No special infrastructure

**Cons:**
- **Inefficient** (constant polling wastes bandwidth)
- Higher latency (up to poll interval)
- More server load

**Why rejected:** Poor UX for chat. SignalR uses this as last-resort fallback.

### Option C: WebSockets (Raw, No Library)
**How it works:**
- Use browser WebSocket API directly
- Implement protocol ourselves

**Pros:**
- Full control
- No library overhead

**Cons:**
- **Reinvent the wheel** (reconnection, fallback, auth)
- More bugs
- Harder to maintain

**Why rejected:** SignalR solves all these problems. Don't reinvent.

### Option D: Socket.IO (Node.js Library)
**How it works:**
- Popular WebSocket library for Node.js

**Pros:**
- Very mature
- Great documentation
- Large ecosystem

**Cons:**
- **Node.js only** (we're .NET)
- Would need separate Node.js server
- Extra infrastructure complexity

**Why rejected:** We're .NET, SignalR is the .NET equivalent.

### Option E: gRPC Streaming
**How it works:**
- Use gRPC bidirectional streaming

**Pros:**
- High performance
- Strongly typed (protobuf)

**Cons:**
- Requires HTTP/2
- Not supported in all browsers
- More complex setup
- Overkill for chat

**Why rejected:** SignalR is easier, better browser support.

### Option F: GraphQL Subscriptions
**How it works:**
- GraphQL over WebSocket

**Pros:**
- Works well with GraphQL queries/mutations
- Typed schema

**Cons:**
- We don't use GraphQL for API
- Would need to adopt GraphQL ecosystem
- More complexity

**Why rejected:** We use REST API. GraphQL is overkill.

## Implementation Details

### Backend (Hub Configuration)

**ChatHub.cs:**
```csharp
public class ChatHub : Hub
{
    private readonly IChatService _chatService;

    public ChatHub(IChatService chatService)
    {
        _chatService = chatService;
    }

    public async Task SendMessage(string message)
    {
        var userId = Context.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        // Stream AI response token-by-token
        await foreach (var token in _chatService.GetStreamingResponseAsync(message, userId))
        {
            await Clients.Caller.SendAsync("ReceiveToken", token);
        }

        await Clients.Caller.SendAsync("StreamComplete");
    }

    public override async Task OnConnectedAsync()
    {
        var userId = Context.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        await Groups.AddToGroupAsync(Context.ConnectionId, userId);
        await base.OnConnectedAsync();
    }
}
```

**Program.cs:**
```csharp
// Add SignalR
builder.Services.AddSignalR();

// Map hub endpoint
app.MapHub<ChatHub>("/hubs/chat");
```

### Frontend (React Client)

**useChatHub.ts:**
```typescript
import * as signalR from '@microsoft/signalr';

export function useChatHub() {
  const [connection, setConnection] = useState<signalR.HubConnection | null>(null);

  useEffect(() => {
    const newConnection = new signalR.HubConnectionBuilder()
      .withUrl('/hubs/chat', {
        accessTokenFactory: () => localStorage.getItem('jwt') || ''
      })
      .withAutomaticReconnect()
      .configureLogging(signalR.LogLevel.Information)
      .build();

    setConnection(newConnection);

    newConnection.start()
      .then(() => console.log('Connected to ChatHub'))
      .catch(err => console.error('SignalR connection failed:', err));

    return () => {
      newConnection.stop();
    };
  }, []);

  const sendMessage = async (message: string) => {
    if (connection) {
      await connection.invoke('SendMessage', message);
    }
  };

  const onReceiveToken = (callback: (token: string) => void) => {
    connection?.on('ReceiveToken', callback);
  };

  return { sendMessage, onReceiveToken };
}
```

**ChatWindow.tsx:**
```typescript
function ChatWindow() {
  const { sendMessage, onReceiveToken } = useChatHub();
  const [response, setResponse] = useState('');

  useEffect(() => {
    onReceiveToken((token) => {
      setResponse(prev => prev + token);
    });
  }, []);

  return (
    <div>
      <div>{response}</div>
      <button onClick={() => sendMessage('Hello AI!')}>Send</button>
    </div>
  );
}
```

## Scalability Strategy

### Current (Single Server)
- All connections handled by one ASP.NET server
- Works for 100-1000 concurrent users

### Future (Horizontal Scaling)

**Option 1: Azure SignalR Service (Recommended)**
- Offload connection management to Azure
- Backplane handled automatically
- Scale to 100K+ concurrent connections
- Pay per message/connection

**Option 2: Redis Backplane**
- Self-hosted Redis for message distribution
- All SignalR servers subscribe to Redis pub/sub
- More control, but need to manage Redis

**Configuration:**
```csharp
builder.Services.AddSignalR()
    .AddAzureSignalR(connectionString); // Azure SignalR

// OR

builder.Services.AddSignalR()
    .AddStackExchangeRedis(redisConnection); // Redis backplane
```

## Authentication

**JWT Token in Connection:**
```typescript
new signalR.HubConnectionBuilder()
  .withUrl('/hubs/chat', {
    accessTokenFactory: () => localStorage.getItem('jwt') || ''
  })
```

**Backend Validation:**
```csharp
app.MapHub<ChatHub>("/hubs/chat")
   .RequireAuthorization(); // Validates JWT
```

## Error Handling

**Automatic Reconnection:**
```typescript
.withAutomaticReconnect([0, 2000, 10000, 30000]) // Retry delays
```

**Manual Handling:**
```typescript
connection.onreconnecting(() => {
  console.log('Reconnecting...');
  showToast('Connection lost, reconnecting...');
});

connection.onreconnected(() => {
  console.log('Reconnected!');
  showToast('Connected');
});

connection.onclose(() => {
  console.log('Connection closed');
  showToast('Disconnected');
});
```

## Performance Considerations

**Connection Limits:**
- Default: 10,000 concurrent connections per server
- Can increase with Azure SignalR Service

**Message Size:**
- Keep messages small (< 32 KB)
- Large data should use REST API + notification via SignalR

**Compression:**
```csharp
builder.Services.AddSignalR()
    .AddMessagePackProtocol(); // Binary protocol (smaller than JSON)
```

## Testing

**Unit Tests:**
- Mock `IHubContext<ChatHub>` in service tests
- Test hub methods directly

**Integration Tests:**
- Use `TestServer` to host hub
- Connect with `HubConnection` client
- Test full flow

```csharp
[Fact]
public async Task SendMessage_StreamsTokens()
{
    var connection = new HubConnectionBuilder()
        .WithUrl("http://localhost/hubs/chat", o => o.HttpMessageHandlerFactory = _ => Server.CreateHandler())
        .Build();

    var tokens = new List<string>();
    connection.On<string>("ReceiveToken", token => tokens.Add(token));

    await connection.StartAsync();
    await connection.InvokeAsync("SendMessage", "Hello");
    await Task.Delay(1000); // Wait for stream

    Assert.NotEmpty(tokens);
}
```

## References

- SignalR Docs: https://docs.microsoft.com/en-us/aspnet/core/signalr/
- Azure SignalR Service: https://azure.microsoft.com/en-us/services/signalr-service/
- SignalR Client (npm): https://www.npmjs.com/package/@microsoft/signalr

---

**Review Date:** 2026-06-01
**Related ADRs:**
- ADR-008: JWT Authentication Strategy
- ADR-009: React 18 + TypeScript Stack
