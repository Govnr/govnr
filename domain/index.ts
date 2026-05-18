export type EntityId = string;

export interface DomainEvent {
  readonly id: EntityId;
  readonly occurredAt: Date;
  readonly type: string;
}

