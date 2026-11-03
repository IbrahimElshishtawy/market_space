import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export interface AccountContext {
  readonly accountId: string;
  readonly userId: string;
  readonly accountType:
    'individual' | 'company' | 'factory' | 'office' | 'store';
  readonly memberRole: 'owner' | 'manager' | 'lister' | 'responder';
  readonly permissions: ReadonlySet<string>;
}

export const CurrentAccount = createParamDecorator(
  (data: keyof AccountContext | undefined, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    const accountContext = request.accountContext as AccountContext;

    return data ? accountContext?.[data] : accountContext;
  },
);
